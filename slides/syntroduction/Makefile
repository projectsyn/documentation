.PHONY: all
all: slides.html slides.pdf

.PHONY: serve
serve: slides.html
	caddy run

slides.html: slides.adoc
	docker run --rm --tty --user "$$(id -u)" --volume "$${PWD}":/build vshn/asciidoctor-slides:1.7 --filename slides.adoc

slides.pdf: slides.html
	docker run --rm --tty --user "$$(id -u)" --volume "$${PWD}":/slides astefanutti/decktape:2.11.0 --size '2560x1440' --pause 2000 --chrome-arg=--allow-file-access-from-files slides.html slides.pdf

.PHONY: clean
clean:
	find . -maxdepth 1 -name '*.adoc' | sed 's/.adoc$$/.html/' | xargs rm -f
	find . -maxdepth 1 -name '*.adoc' | sed 's/.adoc$$/.pdf/' | xargs rm -f
	find . -maxdepth 1 -name 'theme' | xargs rm -rf
	find . -maxdepth 1 -name 'node_modules' | xargs rm -rf
