pages   := $(shell find . -type f -name '*.adoc')
out_dir := ./_public

docker_cmd  ?= docker
docker_opts ?= --rm --tty --user "$$(id -u)"

antora_cmd  ?= $(docker_cmd) run $(docker_opts) --volume "$${PWD}":/antora vshn/antora:2.3.3
antora_opts ?= --cache-dir=.cache/antora

asciidoctor_cmd  ?= $(docker_cmd) run $(docker_opts) --volume "$${PWD}":/documents/ asciidoctor/docker-asciidoctor asciidoctor
asciidoctor_opts ?= --destination-dir=$(out_dir)
asciidoctor_kindle_opts ?= --attribute ebook-format=kf8

vale_cmd ?= $(docker_cmd) run $(docker_opts) --volume "$${PWD}"/docs/modules/ROOT/pages:/pages vshn/vale:2.6.1 --minAlertLevel=error /pages
hunspell_cmd ?= $(docker_cmd) run $(docker_opts) --volume "$${PWD}":/spell vshn/hunspell:1.7.0 -d en,vshn -l -H _public/**/*.html
htmltest_cmd ?= $(docker_cmd) run $(docker_opts) --volume "$${PWD}"/_public:/test wjdp/htmltest:v0.12.0
preview_cmd ?= $(docker_cmd) run --rm --publish 35729:35729 --publish 2020:2020 --volume "${PWD}":/preview/antora vshn/antora-preview:2.3.6 --antora=docs --style=syn

yaml_files      ?= $(shell find . -type f -name '*.yaml' -or -name '*.yml')
yamllint_args   ?= --no-warnings
yamllint_config ?= .yamllint.yml
yamllint_image  ?= docker.io/cytopia/yamllint:latest
yamllint_docker ?= $(docker_cmd) run $(docker_opts) --volume "$${PWD}:/src" --workdir /src $(yamllint_image)


.PHONY: all
all: html

# This will clean the Antora Artifacts, not the npm artifacts
.PHONY: clean
clean:
	rm -rf $(out_dir) '?' .cache

.PHONY: check
check:
	$(vale_cmd) lint_yaml

.PHONY: vale
vale:
	$(vale_cmd)

.PHONY: lint_yaml
lint_yaml: $(yaml_files)
	$(yamllint_docker) -f parsable -c $(yamllint_config) $(yamllint_args) -- $?

# This target lists the images not used in the final website,
# and which could be removed. This command requires `ag` installed:
# https://github.com/ggreer/the_silver_searcher
.PHONY: unused_images
unused_images: html
	@for file in docs/modules/ROOT/assets/images/* ; do \
		if ! ag -U $${file##*/} _public > /dev/null; then \
			echo $$file; \
		fi; \
	done;

.PHONY: syntax
syntax: html
	$(hunspell_cmd)

.PHONY: htmltest
htmltest: html pdf epub kindle manpage
	$(htmltest_cmd)

.PHONY: preview
preview:
	$(preview_cmd)

.PHONY: html
html:    $(out_dir)/index.html

$(out_dir)/index.html: playbook.yml $(pages)
	$(antora_cmd) $(antora_opts) $<
