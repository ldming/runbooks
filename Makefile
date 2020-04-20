# Exclude vendor and dot directories, but do include the `.gitlab` directory
VERIFY_PATH_SELECTOR := \( -not \( -path "*/vendor/*" -o -path "*/.*/*" \) -o -path "*/.gitlab/*" \)

JSONNET_FMT_FLAGS := --string-style s -n 2
JSONNET_FILES = $(shell find . \( -name "*.jsonnet" -o -name "*.libsonnet" \)  -type f $(VERIFY_PATH_SELECTOR) )

SHELL_FMT_FLAGS := -i 2 -ci
SHELL_FILES = $(shell find . -type f \( -perm -u=x -o -name "*.sh" \) $(VERIFY_PATH_SELECTOR) -print0|xargs -0 file -n |grep 'Bourne-Again'|cut -d: -f1)

YAML_FILES = $(shell find . \( -name "*.yml" -o -name "*.yaml" \) -type f $(VERIFY_PATH_SELECTOR) )

JSONET_COMMAND = $(shell which jsonnetfmt || (which jsonnet && echo " fmt"))
PROMTOOL_COMMAND = $(shell which promtool || echo "/prometheus/promtool")

SHELLCHECK_FLAGS := -e SC1090,SC1091

.PHONY: all
all: verify

.PHONY: verify
verify: verify-shellcheck verify-fmt

.PHONY: verify-fmt
verify-fmt:
	$(JSONET_COMMAND) $(JSONNET_FMT_FLAGS) --test $(JSONNET_FILES)
	shfmt $(SHELL_FMT_FLAGS) -l -d $(SHELL_FILES)

.PHONY: verify-shellcheck
verify-shellcheck:
	shellcheck $(SHELLCHECK_FLAGS) $(SHELL_FILES)

.PHONY: fmt
fmt: jsonnet-fmt shell-fmt
	git diff --exit-code

.PHONY: jsonnet-fmt
jsonnet-fmt:
	$(JSONET_COMMAND) $(JSONNET_FMT_FLAGS) -i $(JSONNET_FILES)

.PHONY: shell-fmt
shell-fmt:
	shfmt $(SHELL_FMT_FLAGS) -w $(SHELL_FILES)

.PHONY: generate
generate:
	rm -rf rules/autogenerated-*
	./scripts/generate-jsonnet-rules.sh
	./scripts/generate-docs
	./scripts/generate-gitlab-dashboards.sh
	./scripts/generate-blackbox-urls.sh

.PHONY: test
test:
	./scripts/validate-service-mappings
	$(PROMTOOL_COMMAND) check rules rules/*.yml thanos-rules/*.yml
	# Prometheus config checks are stricter than rules checks, so use a fake config to check this too
	$(PROMTOOL_COMMAND)  check config scripts/prometheus.yml
	./scripts/validate_kibana_urls
	./scripts/validate-alerts
	if ! $$(command -v yaml-lint); then echo "Please install yaml-lint with 'gem install -N yaml-lint'"; exit 1; fi
	yaml-lint $(YAML_FILES)

