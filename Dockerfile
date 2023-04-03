ARG GL_ASDF_AMTOOL_VERSION
ARG GL_ASDF_GO_JSONNET_VERSION
ARG GL_ASDF_JB_VERSION
ARG GL_ASDF_JSONNET_TOOL_VERSION
ARG GL_ASDF_PROMTOOL_VERSION
ARG GL_ASDF_RUBY_VERSION
ARG GL_ASDF_SHELLCHECK_VERSION
ARG GL_ASDF_SHFMT_VERSION
ARG GL_ASDF_TERRAFORM_VERSION
ARG GL_ASDF_THANOS_VERSION
ARG GL_ASDF_YQ_VERSION

# Referenced container images
FROM docker.io/mikefarah/yq:${GL_ASDF_YQ_VERSION} as yq
FROM hashicorp/terraform:${GL_ASDF_TERRAFORM_VERSION} AS terraform
FROM koalaman/shellcheck:v${GL_ASDF_SHELLCHECK_VERSION} AS shellcheck
FROM mvdan/shfmt:v${GL_ASDF_SHFMT_VERSION}-alpine as shfmt
FROM quay.io/prometheus/alertmanager:v${GL_ASDF_AMTOOL_VERSION} AS amtool
FROM quay.io/prometheus/prometheus:v${GL_ASDF_PROMTOOL_VERSION} AS promtool
FROM quay.io/thanos/thanos:v${GL_ASDF_THANOS_VERSION} AS thanos
FROM registry.gitlab.com/gitlab-com/gl-infra/jsonnet-tool:v${GL_ASDF_JSONNET_TOOL_VERSION} AS jsonnet-tool
FROM registry.gitlab.com/gitlab-com/gl-infra/third-party-container-images/go-jsonnet:v${GL_ASDF_GO_JSONNET_VERSION} AS go-jsonnet
FROM registry.gitlab.com/gitlab-com/gl-infra/third-party-container-images/jb:v${GL_ASDF_JB_VERSION} AS jb

# Main stage build
FROM ruby:${GL_ASDF_RUBY_VERSION}-alpine

RUN apk add --no-cache \
  python3 curl bash build-base git jq make \
  openssl tar yamllint zlib npm \
  parallel coreutils

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# Download and install gcloud
RUN curl --silent -o /tmp/google-cloud-sdk.tar.gz -L --fail  https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz && \
  mkdir -p /usr/local/gcloud && \
  tar -C /usr/local/gcloud -xf /tmp/google-cloud-sdk.tar.gz && \
  rm /tmp/google-cloud-sdk.tar.gz && \
  /usr/local/gcloud/google-cloud-sdk/install.sh && \
  gcloud components install kubectl -q

# Install binary tools
COPY --from=amtool /bin/amtool /bin/amtool
COPY --from=go-jsonnet /usr/bin/jsonnet /bin/jsonnet
COPY --from=go-jsonnet /usr/bin/jsonnetfmt /bin/jsonnetfmt
COPY --from=jb /usr/bin/jb /bin/jb
COPY --from=jsonnet-tool /usr/local/bin/jsonnet-tool /bin/jsonnet-tool
COPY --from=promtool /bin/promtool /bin/promtool
COPY --from=shellcheck /bin/shellcheck /bin/shellcheck
COPY --from=shfmt /bin/shfmt /bin/shfmt
COPY --from=terraform /bin/terraform /bin/terraform
COPY --from=thanos /bin/thanos /bin/thanos
COPY --from=yq /usr/bin/yq /usr/bin/yq

ENTRYPOINT ["/bin/sh", "-c"]
