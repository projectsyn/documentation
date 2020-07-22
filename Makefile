MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

pages   := $(shell find . -type f -name '*.adoc')
web_dir := ./_antora

ANTORA_CMD   ?= $(DOCKER_CMD) $(DOCKER_ARGS) --volume "$${PWD}":/antora vshn/antora:2.3.0
ANTORA_ARGSS ?= --cache-dir=.cache/antora

DOCKER_CMD  ?= docker
DOCKER_ARGS ?= run --rm --user "$$(id -u)" --volume "$${PWD}:/src" --workdir /src

YAML_FILES      ?= $(shell find . -type f -name '*.yaml' -or -name '*.yml')
YAMLLINT_ARGS   ?= --no-warnings
YAMLLINT_CONFIG ?= .yamllint.yml
YAMLLINT_IMAGE  ?= docker.io/cytopia/yamllint:latest
YAMLLINT_DOCKER ?= $(DOCKER_CMD) $(DOCKER_ARGS) $(YAMLLINT_IMAGE)

VALE_CMD  ?= $(DOCKER_CMD) $(DOCKER_ARGS) --volume "$${PWD}"/docs/modules:/pages vshn/vale:2.1.1
VALE_ARGS ?= --minAlertLevel=error --config=/pages/ROOT/pages/.vale.ini /pages

UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
	OS = linux-x64
	OPEN = xdg-open
endif
ifeq ($(UNAME), Darwin)
	OS = darwin-x64
	OPEN = open
endif

.PHONY: all
all: lint docs open

# This will clean the Antora Artifacts, not the npm artifacts
.PHONY: clean
clean:
	rm -rf $(web_dir)

.PHONY: open
open: $(web_dir)/index.html
	-$(OPEN) $<

.PHONY: docs
docs:    $(web_dir)/index.html

$(web_dir)/index.html: playbook.yml $(pages)
	$(ANTORA_CMD) $(ANTORA_ARGSS) $<

.PHONY: lint
lint: lint_yaml lint_adoc

.PHONY: lint_yaml
lint_yaml: $(YAML_FILES)
	$(YAMLLINT_DOCKER) -f parsable -c $(YAMLLINT_CONFIG) $(YAMLLINT_ARGS) -- $?

.PHONY: lint_adoc
lint_adoc:
	$(VALE_CMD) $(VALE_ARGS)
