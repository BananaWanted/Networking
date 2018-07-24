PROJECT_NAME = Networking
PROJECT_URL = https://github.com/BananaWanted/Networking
APPS = dns misc
BASE_APPS = sanic sqitch
SHELL = bash
BUILD_TAG ?= BUILD-$(or $(TRAVIS_BUILD_NUMBER), debug)
CURRENT_BRANCH ?= $(or $(TRAVIS_PULL_REQUEST_BRANCH), $(TRAVIS_BRANCH), $(shell git rev-parse --abbrev-ref HEAD))
IS_PULL_REQUEST ?= $(or $(TRAVIS_PULL_REQUEST), false)
RELEASE_NAME ?= release-prod
DOCKER_HUB_USERNAME ?= library
DOCKER_HUB_PASSWORD ?=
DOCKER_BUILD_ARGS = --build-arg DOCKER_HUB_USERNAME=$(DOCKER_HUB_USERNAME) --build-arg BUILD_TAG=$(BUILD_TAG)
GITHUB_TOKEN ?=

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
			if ! ( docker pull $(DOCKER_HUB_USERNAME)/$@:latest && docker pull $(DOCKER_HUB_USERNAME)/$@:latest-test ); then \
				app_not_exists=yes; \
			fi; \
		fi; \
		if [[ -n "$$app_modified" || -n "$$app_not_exists" ]]; then \
			$(MAKE) docker-build-app-$@; \
		else \
			$(MAKE) docker-retag-app-$@; \
		fi; \
	fi

docker-build-app-%:
	docker build $(DOCKER_BUILD_ARGS) -t $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG) -f applications/$*/Dockerfile applications/$*
	docker build $(DOCKER_BUILD_ARGS) -t $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG)-test -f applications/$*/Dockerfile-test applications/$*

docker-retag-app-%:
	docker tag $(DOCKER_HUB_USERNAME)/$*:latest $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG)
	docker tag $(DOCKER_HUB_USERNAME)/$*:latest-test $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG)-test

docker-push-app-%:
	@echo pushing $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG)
	docker push $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG)
	docker push $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG)-test
ifeq ($(IS_PULL_REQUEST), false)
	# override latest for master builds
	docker tag $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG) $(DOCKER_HUB_USERNAME)/$*:latest
	docker push $(DOCKER_HUB_USERNAME)/$*:latest
	docker tag $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG)-test $(DOCKER_HUB_USERNAME)/$*:latest-test
	docker push $(DOCKER_HUB_USERNAME)/$*:latest-test
endif
	# tag branch name for all builds
	docker tag $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG) $(DOCKER_HUB_USERNAME)/$*:$(CURRENT_BRANCH)
	docker push $(DOCKER_HUB_USERNAME)/$*:$(CURRENT_BRANCH)
	docker tag $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG)-test $(DOCKER_HUB_USERNAME)/$*:$(CURRENT_BRANCH)-test
	docker push $(DOCKER_HUB_USERNAME)/$*:$(CURRENT_BRANCH)-test

sleep-%:
	sleep $*

sqitch-%:
	# examples:
	# 	make sqitch-add ARGS=""
	# 	make sqitch-deploy
	docker run --rm -v `realpath .`/applications/db-vcs/sqitch:/src docteurklein/sqitch:pgsql $* $(ARGS)

noerror-%:
	-$(MAKE) $*

# you may create a Makefile-local to override the variables.
include Makefile-*