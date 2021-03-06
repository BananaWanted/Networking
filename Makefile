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
ACME_EMAIL ?= acme@a.com
GCP_DNS_PROJECT ?= gcp_dns_project
GCP_DNS_KEY_FILE ?= service_account_key.json
DDNS_ZONE ?= local
AUTH0_DOMAIN ?= my.auth0.domain
AUTH0_CLIENT_ID ?= my-client-id
AUTH0_JWT_CERT ?= auth0-jwt.cert
SERVICE_HOSTS ?= {*}

HELM_COMMON_FLAGS ?= --wait \
					--set dockerRegistry=$(DOCKER_REGISTRY),buildTag=$(BUILD_TAG) \
					--set appConfigs.dns.env.DDNS_ZONE=$(DDNS_ZONE) \
					--set hosts="$(SERVICE_HOSTS)" \
					--set ACME.email="$(ACME_EMAIL)" \
					--set ACME.dns.project="$(GCP_DNS_PROJECT)"

.PHONY: $(sort $(APPS) $(BASE_APPS) $(sort $(dir $(wildcard */))) all clean install test)

all: $(APPS)
	# After a full rebuilding, bump up the Chart version.
	# This operation is safe to fail.
	-$(HELM) local-chart-version bump -s patch -c .


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
	docker run --rm -it -e TESTING=true -e SANIC_TESTING=true -e TEST_STAGE=BUILD \
		$(DOCKER_REGISTRY)/$*:$(BUILD_TAG)-test \
		sh -c '$${RUN_TEST}'

debug-app-%:
	docker run --rm -it -e TESTING=true -e SANIC_TESTING=true \
		$(DOCKER_REGISTRY)/$*:$(BUILD_TAG)-test \
		sh -c '$${RUN_TEST} $${DEBUG_FLAGS}'

sleep-%:
	sleep $*

sqitch-%: env-sqitch
	$(SQITCH) $* $(ARGS)

noerror-%:
	-$(MAKE) $*

# you may create a Makefile-local to override the variables.
include Makefile-*