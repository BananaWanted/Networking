APPS := dns misc
BASE_APPS := sanic
CURRENT_BRANCH := $(TRAVIS_PULL_REQUEST_BRANCH:-$(TRAVIS_BRANCH))
DOCKER_HUB_USERNAME := $(DOCKER_HUB_USERNAME:-library)
BUILD_TAG := BUILD-$(TRAVIS_BUILD_NUMBER)

.PHONY: $(sort $(APPS) $(BASE_APPS) $(sort $(dir $(wildcard */))) all clean install test)
SHELL := bash

all: $(APPS)

ci_build: ci_git_login ci_docker_login all ci_docker_push_images ci_tag_the_commit

$(APPS): $(BASE_APPS)

$(APPS) $(BASE_APPS):
	# all builds:
	#	tag current commit with the CI build number in BUILD-<#> format
	#	tag image with build number (BUILD-<#>) if build succeed
	# PR builds:
	#	build modified apps (by compare with master) / newly created apps (by trying to pull from "latest")
	#	tag image with PR branch name, both existed apps & newly built apps
	# master builds:
	#	build all apps
	#	tag with build number and "latest" and "master"
	set -e; \
	if [[ $(TRAVIS_PULL_REQUEST) = "false" ]]; then \
		$(MAKE) docker-build-app-$@; \
	else \
		if ! git diff --no-ext-diff --exit-code origin/master -- applications/$@ 2>&1 >/dev/null; then \
			app_modified=yes; \
		else \
			if ! docker pull $(DOCKER_HUB_USERNAME)/$@; then \
				app_not_exists=yes; \
			fi; \
		fi; \
	fi; \
	if [[ -n "$$app_modified" || -n "$$app_not_exists" ]]; then \
		$(MAKE) docker-build-app-$@; \
	else \
		$(MAKE) docker-retag-app-$@; \
	fi

docker-build-app-%:
	docker build --pull --no-cache -t $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG) applications/$*
	docker build --pull --no-cache -t $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG)-test -f applications/$*/Dockerfile-test applications/$*

docker-retag-app-%:
	docker tag $(DOCKER_HUB_USERNAME)/$*:latest $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG)
	docker tag $(DOCKER_HUB_USERNAME)/$*:latest-test $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG)-test

docker-push-app-%:
	@echo pushing $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG)
	docker push $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG)
	docker push $(DOCKER_HUB_USERNAME)/$*:$(BUILD_TAG)-test
ifeq ($(TRAVIS_PULL_REQUEST), false)
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

ci_git_set_username_travis:
	git config user.email "builds@travis-ci.org"
	git config user.name "Travis CI"

ci_git_login:
	@git remote set-url origin $(shell git remote get-url origin | sed "s#https://#https://$(GITHUB_TOKEN)@#g")

ci_tag_the_commit:
	git tag $(BUILD_TAG)
	git push origin $(BUILD_TAG)

ci_docker_login:
	docker login -u $(DOCKER_HUB_USERNAME) -p $(DOCKER_HUB_PASSWORD)

ci_docker_push_images:
	# Use a dedicated job to push all images after all build succeed.
	$(foreach app, $(APP) $(BASE_APPS), $(call docker-push-app-$(app)))

system_name := $(shell uname -s)
helm_install_cmd := $(if ifeq($(system_name), "Darwin), brew install kubernetes-helm, set -o pipefail; curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash)
kube_check_cluster_connectivity := set -o pipefail; kubectl cluster-info --request-timeout=10 2>/dev/null | head -n 1

helm_install:
	$(helm_install_cmd)
	$(kube_check_cluster_connectivity)