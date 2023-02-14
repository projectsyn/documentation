pages   := $(shell find . -type f -name '*.adoc')
out_dir := ./_public

docker_cmd  ?= docker
docker_opts ?= --rm --tty --user "$$(id -u)"

vale_cmd ?= $(docker_cmd) run $(docker_opts) --volume "$${PWD}"/docs/modules/ROOT/pages:/pages --workdir /pages docker.io/vshn/vale:2.10.5.1 --minAlertLevel=error /pages
preview_cmd ?= $(docker_cmd) run --rm --publish 35729:35729 --publish 2020:2020 --volume "${PWD}":/preview/antora docker.io/vshn/antora-preview:3.1.1.1 --antora=docs --style=syn

.PHONY: all
all: html

# This will clean the Antora Artifacts, not the npm artifacts
.PHONY: clean
clean:
	rm -rf $(out_dir) '?' .cache

.PHONY: check
check:
	$(vale_cmd)

.PHONY: preview
preview:
	$(preview_cmd)
