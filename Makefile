PREFIX ?= /usr
DESTDIR ?=
INSTALL ?= install
RM ?= rm -f

.DEFAULT_GOAL := help

.PHONY: help install uninstall validate build clean

help:
	@echo "Available targets:"
	@echo "  make build"
	@echo "  make install"
	@echo "  make uninstall"
	@echo "  make validate"

install:
	$(INSTALL) -Dm755 src/usr/bin/argvus-widget-telemetry-toggle "$(DESTDIR)$(PREFIX)/bin/argvus-widget-telemetry-toggle"
	ln -sfn "$(PREFIX)/bin/argvus-widget-telemetry-toggle" "$(DESTDIR)$(PREFIX)/bin/argvus-desktop-telemetry-toggle"
	$(INSTALL) -dm755 "$(DESTDIR)$(PREFIX)/share/argvus/widget-telemetry"
	cp -R --no-preserve=ownership src/usr/share/argvus/widget-telemetry/. "$(DESTDIR)$(PREFIX)/share/argvus/widget-telemetry/"
	find "$(DESTDIR)$(PREFIX)/share/argvus/widget-telemetry/sh" -type f -name '*.sh' -exec chmod 755 {} \;
	$(INSTALL) -Dm644 LICENSE "$(DESTDIR)$(PREFIX)/share/licenses/argvus-widget-telemetry/LICENSE"

uninstall:
	$(RM) "$(DESTDIR)$(PREFIX)/bin/argvus-widget-telemetry-toggle"
	$(RM) "$(DESTDIR)$(PREFIX)/bin/argvus-desktop-telemetry-toggle"
	rm -rf "$(DESTDIR)$(PREFIX)/share/argvus/widget-telemetry"
	$(RM) "$(DESTDIR)$(PREFIX)/share/licenses/argvus-widget-telemetry/LICENSE"

validate:
	@set -eu; \
	test -x src/usr/bin/argvus-widget-telemetry-toggle; \
	test -x src/usr/share/argvus/widget-telemetry/sh/network.sh; \
	test -f src/usr/share/argvus/widget-telemetry/config/argvus-widget-telemetry.jsonc; \
	test -f src/usr/share/argvus/widget-telemetry/config/argvus-widget-telemetry.css; \
	scripts="src/usr/bin/argvus-widget-telemetry-toggle $$(find src/usr/share/argvus/widget-telemetry/sh -type f -name '*.sh' | sort)"; \
	for script in $$scripts; do sh -n "$$script"; done; \
	if command -v shellcheck >/dev/null 2>&1; then shellcheck -e SC1090 -e SC1091 -e SC2034 $$scripts; else echo "shellcheck not found; skipped"; fi; \
	for theme in src/usr/share/argvus/widget-telemetry/config/themes/*; do test -f "$$theme/widget-telemetry-theme.css"; done
	@echo "argvus-widget-telemetry validation ok"

build:
	@tools/build-local-package.sh

clean:
	rm -rf dist
	rm -f packaging/arch/*.zst packaging/arch/*.tar.gz
