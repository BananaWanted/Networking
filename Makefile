APPS := dns misc db-vcs
BASE_APPS := sanic sqitch wait-for-db
SHELL := bash
BUILD_TAG ?= BUILD-$(or $(TRAVIS_BUILD_NUMBER), debug)
CURRENT_BRANCH ?= $(or $(TRAVIS_PULL_REQUEST_BRANCH), $(TRAVIS_BRANCH), $(shell git rev-parse --abbrev-ref HEAD))
IS_PULL_REQUEST ?= $(or $(TRAVIS_PULL_REQUEST), false)
HELM_RELEASE_NAME ?= release-prod
DOCKER_REGISTRY ?= library
DOCKER_PASSWORD ?=
DOCKER_BUILD_ARGS ?= --build-arg DOCKER_REGISTRY=$(DOCKER_REGISTRY) --build-arg BUILD_TAG=$(BUILD_TAG)
GITHUB_TOKEN ?=
DDNS_ZONE ?= local
ACME_EMAIL ?= acme@a.com
ACME_DNS_PROJECT ?= acme_dns_project
# TODO merge ACME_DNS_PROJECT and PROD_GCP_DNS_PROJECT
SERVICE_HOSTS ?= {*}

HELM_COMMON_FLAGS ?= --wait \
					--set dockerRegistry=$(DOCKER_REGISTRY),buildTag=$(BUILD_TAG) \
					--set appConfigs.dns.env.DDNS_ZONE=$(DDNS_ZONE) \
					--set hosts="$(SERVICE_HOSTS)" \
					--set ACME.email="$(ACME_EMAIL)" \
					--set ACME.dns.project="$(ACME_DNS_PROJECT)"

.PHONY: $(sort $(APPS) $(BASE_APPS) $(sort $(dir $(wildcard */))) all clean install test)

all: $(APPS)

$(APPS): $(BASE_APPS)

# all builds:
#	tag current commit with the CI build number in BUILD-<#> format
#	tag image with build number (BUILD-<#>) if build succeed
# PR builds:
#	build modified apps (by compare with master) / newly created apps (by trying to pull from "latest")
#	tag image with PR branch name, both existed apps & newly built apps
# master builds:
#	build all apps
#	tag with build number and "latest" and "master"
$(APPS) $(BASE_APPS):
	@set -e; \
	if [[ $(IS_PULL_REQUEST) = "false" ]]; then \
		$(MAKE) docker-build-app-$@; \
	else \
		if ! git diff --no-ext-diff --exit-code origin/master -- applications/$@ 2>&1 >/dev/null; then \
			app_modified=yes; \
		else \
			if ! ( docker pull $(DOCKER_REGISTRY)/$@:latest && docker pull $(DOCKER_REGISTRY)/$@:latest-test ); then \
				app_not_exists=yes; \
			fi; \
		fi; \
		if [[ -n "$$app_modified" || -n "$$app_not_exists" ]]; then \
			$(MAKE) docker-build-app-$@; \
		else \
			$(MAKE) docker-retag-app-$@; \
		fi; \
	fi
	$(MAKE) test-app-$@

docker-build-app-%:
	docker build $(DOCKER_BUILD_ARGS) -t $(DOCKER_REGISTRY)/$*:$(BUILD_TAG) -f applications/$*/Dockerfile applications/$*
	docker build $(DOCKER_BUILD_ARGS) -t $(DOCKER_REGISTRY)/$*:$(BUILD_TAG)-test -f applications/$*/Dockerfile-test applications/$*

docker-retag-app-%:
	docker tag $(DOCKER_REGISTRY)/$*:latest $(DOCKER_REGISTRY)/$*:$(BUILD_TAG)
	docker tag $(DOCKER_REGISTRY)/$*:latest-test $(DOCKER_REGISTRY)/$*:$(BUILD_TAG)-test

docker-push-app-%:
	@echo pushing $(DOCKER_REGISTRY)/$*:$(BUILD_TAG)
	docker push $(DOCKER_REGISTRY)/$*:$(BUILD_TAG)
	docker push $(DOCKER_REGISTRY)/$*:$(BUILD_TAG)-test
ifeq ($(IS_PULL_REQUEST), false)
	# override latest for master builds
	docker tag $(DOCKER_REGISTRY)/$*:$(BUILD_TAG) $(DOCKER_REGISTRY)/$*:latest
	docker push $(DOCKER_REGISTRY)/$*:latest
	docker tag $(DOCKER_REGISTRY)/$*:$(BUILD_TAG)-test $(DOCKER_REGISTRY)/$*:latest-test
	docker push $(DOCKER_REGISTRY)/$*:latest-test
endif
	# tag branch name for all builds
	docker tag $(DOCKER_REGISTRY)/$*:$(BUILD_TAG) $(DOCKER_REGISTRY)/$*:$(CURRENT_BRANCH)
	docker push $(DOCKER_REGISTRY)/$*:$(CURRENT_BRANCH)
	docker tag $(DOCKER_REGISTRY)/$*:$(BUILD_TAG)-test $(DOCKER_REGISTRY)/$*:$(CURRENT_BRANCH)-test
	docker push $(DOCKER_REGISTRY)/$*:$(CURRENT_BRANCH)-test

test-app-%:
	# docker run --rm -it -e TEST_IT=yes $(DOCKER_REGISTRY)/$*:$(BUILD_TAG)-test
	docker run --rm -it $(DOCKER_REGISTRY)/$*:$(BUILD_TAG)-test

sleep-%:
	sleep $*

sqitch-%: env-sqitch
	$(SQITCH) $* $(ARGS)

noerror-%:
	-$(MAKE) $*

# you may create a Makefile-local to override the variables.
include Makefile-*