# ---------- STEP 1 ----------
# Build the HTML slides
FROM vshn/asciidoctor-slides:1.7 as htmlmaker

COPY assets /build/assets
COPY slides.adoc /build/slides.adoc
RUN generate-vshn-slides --filename slides.adoc

# ---------- STEP 2 ----------
# Build the presentation in PDF format
FROM astefanutti/decktape:2.11.0 as pdfmaker

COPY --from=htmlmaker /build/slides.html /slides/slides.html
COPY --from=htmlmaker /build/assets /slides/assets
COPY --from=htmlmaker /presentation/theme /slides/theme
COPY --from=htmlmaker /presentation/node_modules/asciinema-player /slides/node_modules/asciinema-player
COPY --from=htmlmaker /presentation/node_modules/reveal.js /slides/node_modules/reveal.js
COPY --from=htmlmaker /presentation/node_modules/highlightjs /slides/node_modules/highlightjs
COPY --from=htmlmaker /presentation/node_modules/lato-font /slides/node_modules/lato-font
COPY --from=htmlmaker /presentation/node_modules/typeface-ubuntu /slides/node_modules/typeface-ubuntu
COPY --from=htmlmaker /presentation/node_modules/typeface-ubuntu-mono /slides/node_modules/typeface-ubuntu-mono
COPY --from=htmlmaker /presentation/node_modules/@fortawesome /slides/node_modules/@fortawesome
RUN node /decktape/decktape.js --chrome-path chromium-browser --chrome-arg=--no-sandbox --size '2560x1440' --pause 2000 --chrome-arg=--allow-file-access-from-files /slides/slides.html /slides/slides.pdf

# ---------- STEP 3 ----------
# Docker image only containing nginx and the freshly built presentation files
FROM vshn/nginx:1.0

# Finally, copy the contents of the presentation to be served
COPY --from=htmlmaker /build/slides.html /usr/share/nginx/html/index.html
COPY --from=htmlmaker /build/assets /usr/share/nginx/html/assets
COPY --from=htmlmaker /presentation/theme /usr/share/nginx/html/theme
COPY --from=htmlmaker /presentation/node_modules/asciinema-player /usr/share/nginx/html/node_modules/asciinema-player
COPY --from=htmlmaker /presentation/node_modules/reveal.js /usr/share/nginx/html/node_modules/reveal.js
COPY --from=htmlmaker /presentation/node_modules/highlightjs /usr/share/nginx/html/node_modules/highlightjs
COPY --from=htmlmaker /presentation/node_modules/lato-font /usr/share/nginx/html/node_modules/lato-font
COPY --from=htmlmaker /presentation/node_modules/typeface-ubuntu /usr/share/nginx/html/node_modules/typeface-ubuntu
COPY --from=htmlmaker /presentation/node_modules/typeface-ubuntu-mono /usr/share/nginx/html/node_modules/typeface-ubuntu-mono
COPY --from=htmlmaker /presentation/node_modules/@fortawesome /usr/share/nginx/html/node_modules/@fortawesome
COPY --from=pdfmaker /slides/slides.pdf /usr/share/nginx/html/slides.pdf
