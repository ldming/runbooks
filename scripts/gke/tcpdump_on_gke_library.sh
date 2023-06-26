#!/bin/bash

# This file provides library functions used by other scripts in this directory.
# These functions support running packet captures on a GKE node.
# Assumptions:
#  * The "crictl" utility should be installed and configured with a container runtime API endpoint.
#    This is true by default on GKE nodes.
#  * The "toolbox" utility should be installed as a wrapper around systemd-nspawn.
#    This is true by default on GKE nodes.

TOOLBOX_ROOT_BIND_DIR="/media/root"
OUTPUT_DIR_OUTSIDE_TOOLBOX="/var/pcap"
OUTPUT_DIR_INSIDE_TOOLBOX="${TOOLBOX_ROOT_BIND_DIR}${OUTPUT_DIR_OUTSIDE_TOOLBOX}"

function setup_toolbox() {
  echo "Setting up toolbox.  (May take up to a minute during first run.)"
  update_apt_cache
  install_tcpdump_in_toolbox
  install_jq_in_toolbox
  make_output_dir_in_toolbox
}

function update_apt_cache() {
  toolbox apt update -y -qq
}

function install_tcpdump_in_toolbox() {
  toolbox apt install -y -qq tcpdump 2>/dev/null
}

function install_jq_in_toolbox() {
  toolbox apt install -y -qq jq 2>/dev/null
}

function make_output_dir_in_toolbox() {
  toolbox mkdir -p "${OUTPUT_DIR_INSIDE_TOOLBOX}" 2>/dev/null
}

function find_default_net_iface_for_host() {
  NET_IFACE=$(ip route | awk '/^default/ { print $5 }')
  [[ -n $NET_IFACE ]] || die "Could not identify default network interface for host."
}

function find_net_iface_for_pod_id() {
  assert_is_pod_id "${POD_ID}"
  NET_IFACE=$(crictl inspectp "${POD_ID}" | toolbox jq -r '.info.cniResult.Interfaces | with_entries(select(.value.IPConfigs | not)) | keys[0]' 2>/dev/null)
  [[ -n ${NET_IFACE} ]] || die "Could not identify virtual network interface for pod."
}

function find_netns_for_pod_id() {
  assert_is_pod_id "${POD_ID}"
  NET_NS_PATH=$(crictl inspectp "${POD_ID}" | toolbox jq -r '.info.runtimeSpec.linux.namespaces[] | select(.type == "network") | .path' 2>/dev/null)
  [[ -n ${NET_NS_PATH} ]] || die "Could not identify network namespace for pod."
}

function run_tcpdump_in_toolbox_for_iface() {
  [[ -n ${MAX_DURATION_SECONDS} ]] || die "Max capture duration is not defined."
  [[ -n ${NET_IFACE} ]] || die "Network interface to capture is not defined."
  [[ -n ${PCAP_FILENAME} ]] || die "Pcap filename pattern is not defined."
  echo "Capturing to pcap file: ${PCAP_FILENAME}"
  toolbox timeout --preserve-status --signal INT "${MAX_DURATION_SECONDS}" \
    tcpdump -v -i "${NET_IFACE}" -w "${OUTPUT_DIR_INSIDE_TOOLBOX}/${PCAP_FILENAME}" "${EXTRA_TCPDUMP_ARGS[@]}"
}

function run_tcpdump_in_toolbox_for_netns() {
  [[ -n ${MAX_DURATION_SECONDS} ]] || die "Max capture duration is not defined."
  [[ -n ${NET_NS_PATH} ]] || die "Network namespace path to enter for capture is not defined."
  [[ -n ${PCAP_FILENAME} ]] || die "Pcap filename pattern is not defined."
  echo "Capturing to pcap file: ${PCAP_FILENAME}"
  toolbox --network-namespace-path="${NET_NS_PATH}" \
    timeout --preserve-status --signal INT "${MAX_DURATION_SECONDS}" \
    tcpdump -v -i any -w "${OUTPUT_DIR_INSIDE_TOOLBOX}/${PCAP_FILENAME}" "${EXTRA_TCPDUMP_ARGS[@]}"
}

function compress_pcap_file() {
  echo "Compressing pcap file."
  [[ -n ${PCAP_FILENAME} ]] || die "Pcap filename pattern is not defined."
  # We use a wildcard suffix here in case the caller configured tcpdump to do a rotating capture.
  # In that special case, tcpdump appends a counter or timestamp suffix to the filename pattern.
  toolbox find "${OUTPUT_DIR_INSIDE_TOOLBOX}" -name "${PCAP_FILENAME}*" -type f -exec gzip -v {} \; 2>/dev/null
}

function show_pcap_file() {
  echo "Results:"
  ls -lh "${OUTPUT_DIR_OUTSIDE_TOOLBOX}/${PCAP_FILENAME}"*
}

function assert_is_pod_id() {
  local POD_ID=$1
  [[ $POD_ID =~ ^[0-9a-f]{10,64}$ ]] || die "Invalid pod id: '$POD_ID'"
}

function die() {
  echo "ERROR: $*" 1>&2
  exit 1
}
