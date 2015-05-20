INFILES = $(shell shopt -s globstar; for i in **/*.mdwn; do echo $$i; done)
OUTPUT = /srv/www/natalian
OUTFILES = $(INFILES:.mdwn=/index.html)
LIST=$(addprefix $(OUTPUT)/, $(OUTFILES))

all: $(LIST) $(OUTPUT)/index.html style.css

$(OUTPUT)/%/index.html: %.mdwn header.inc footer.inc
	@mkdir -p $(shell dirname $@ || true) || true
	@cat header.inc > $@
	@cmark $< >> $@
	@cat footer.inc >> $@
	@echo $< '→' $@

$(OUTPUT)/index.html: all main.go
	go run main.go > $(OUTPUT)/index.html

$(OUTPUT)/style.css: style.css
	cp style.css $(OUTPUT)/style.css

watch:
	while ! inotifywait -r -e modify .; do make; done

upload: $(OUTPUT)/index.html $(OUTPUT)/style.css
	s3cmd sync -F -rr --delete-removed -P $(OUTPUT)/ s3://natalian.org/

clean:
	rm -rf $(OUTPUT)
