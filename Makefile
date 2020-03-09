JSONNET_FMT_FLAGS := --string-style s -n 2
JSONNET_FILES = $(shell find . \( -name "*.jsonnet" -o -name "*.libsonnet" \)  -type f -not \( -path "./dashboards/vendor/*" -path "./elastic/*" \) )

SHELL_FMT_FLAGS := -i 2 -ci
SHELL_FILES = $(shell find . -name "*.sh" -type f -not -path "./dashboards/vendor/*")

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
	./scripts/generate-key-metric-recording-rules.sh
	./scripts/generate-sidekiq-worker-apdex-scores.sh
	./scripts/generate-docs
	./scripts/generate-sla-recording-rules.sh
	./scripts/generate-gitlab-dashboards.sh

.PHONY: test
test:
	./scripts/validate-service-mappings
	$(PROMTOOL_COMMAND) check rules rules/*.yml thanos-rules/*.yml
	# Prometheus config checks are stricter than rules checks, so use a fake config to check this too
	$(PROMTOOL_COMMAND)  check config scripts/prometheus.yml
	./scripts/validate_kibana_urls
	./scripts/validate-alerts
	if ! $$(command -v yaml-lint); then echo "Please install yaml-lint with 'gem install -N yaml-lint'"; exit 1; fi
	find . -name \*.y*ml | xargs yaml-lint

