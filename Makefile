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
	$(INSTALL) -Dm755 usr/bin/argvus-widget-telemetry-toggle "$(DESTDIR)$(PREFIX)/bin/argvus-widget-telemetry-toggle"
	ln -sfn "$(PREFIX)/bin/argvus-widget-telemetry-toggle" "$(DESTDIR)$(PREFIX)/bin/argvus-desktop-telemetry-toggle"
	$(INSTALL) -dm755 "$(DESTDIR)$(PREFIX)/share/argvus/waybar"
	cp -R --no-preserve=ownership config/waybar/. "$(DESTDIR)$(PREFIX)/share/argvus/waybar/"
	$(INSTALL) -dm755 "$(DESTDIR)$(PREFIX)/share/argvus/scripts/argvus/widget-telemetry"
	cp -R --no-preserve=ownership usr/share/argvus/scripts/argvus/widget-telemetry/. "$(DESTDIR)$(PREFIX)/share/argvus/scripts/argvus/widget-telemetry/"
	find "$(DESTDIR)$(PREFIX)/share/argvus/scripts/argvus/widget-telemetry" -type f -name '*.sh' -exec chmod 755 {} \;
	ln -sfn "$(PREFIX)/share/argvus/scripts/argvus/widget-telemetry" "$(DESTDIR)$(PREFIX)/share/argvus/scripts/argvus/sysinfo"
	ln -sfn "argvus-widget-telemetry.jsonc" "$(DESTDIR)$(PREFIX)/share/argvus/waybar/argvus-sysinfo.jsonc"
	ln -sfn "argvus-widget-telemetry.css" "$(DESTDIR)$(PREFIX)/share/argvus/waybar/argvus-sysinfo.css"
	for theme in config/waybar/themes/*; do ln -sfn "widget-telemetry-theme.css" "$(DESTDIR)$(PREFIX)/share/argvus/waybar/themes/$${theme##*/}/sysinfo-theme.css"; done
	$(INSTALL) -dm755 "$(DESTDIR)$(PREFIX)/share/argvus/scripts/apps"
	ln -sfn "$(PREFIX)/bin/argvus-widget-telemetry-toggle" "$(DESTDIR)$(PREFIX)/share/argvus/scripts/apps/waybar-sysinfo-toggle.sh"
	$(INSTALL) -Dm644 LICENSE "$(DESTDIR)$(PREFIX)/share/licenses/argvus-widget-telemetry/LICENSE"

uninstall:
	$(RM) "$(DESTDIR)$(PREFIX)/bin/argvus-widget-telemetry-toggle"
	$(RM) "$(DESTDIR)$(PREFIX)/bin/argvus-desktop-telemetry-toggle"
	$(RM) "$(DESTDIR)$(PREFIX)/share/argvus/scripts/apps/waybar-sysinfo-toggle.sh"
	$(RM) "$(DESTDIR)$(PREFIX)/share/argvus/waybar/argvus-widget-telemetry.jsonc"
	$(RM) "$(DESTDIR)$(PREFIX)/share/argvus/waybar/argvus-widget-telemetry.css"
	$(RM) "$(DESTDIR)$(PREFIX)/share/argvus/waybar/argvus-sysinfo.jsonc"
	$(RM) "$(DESTDIR)$(PREFIX)/share/argvus/waybar/argvus-sysinfo.css"
	$(RM) "$(DESTDIR)$(PREFIX)/share/argvus/scripts/argvus/sysinfo"
	for script in usr/share/argvus/scripts/argvus/widget-telemetry/*.sh; do $(RM) "$(DESTDIR)$(PREFIX)/share/argvus/scripts/argvus/widget-telemetry/$${script##*/}"; done
	for theme in config/waybar/themes/*; do $(RM) "$(DESTDIR)$(PREFIX)/share/argvus/waybar/themes/$${theme##*/}/widget-telemetry-theme.css"; done
	for theme in config/waybar/themes/*; do $(RM) "$(DESTDIR)$(PREFIX)/share/argvus/waybar/themes/$${theme##*/}/sysinfo-theme.css"; done
	$(RM) "$(DESTDIR)$(PREFIX)/share/licenses/argvus-widget-telemetry/LICENSE"

validate:
	@set -eu; \
	test -x usr/bin/argvus-widget-telemetry-toggle; \
	test -f config/waybar/argvus-widget-telemetry.jsonc; \
	test -f config/waybar/argvus-widget-telemetry.css; \
	scripts="usr/bin/argvus-widget-telemetry-toggle $$(find usr/share/argvus/scripts/argvus/widget-telemetry -type f -name '*.sh' | sort)"; \
	for script in $$scripts; do sh -n "$$script"; done; \
	if command -v shellcheck >/dev/null 2>&1; then shellcheck -e SC1090 -e SC1091 -e SC2034 $$scripts; else echo "shellcheck not found; skipped"; fi; \
	for theme in config/waybar/themes/*; do test -f "$$theme/widget-telemetry-theme.css"; done
	@echo "argvus-widget-telemetry validation ok"

build:
	@tools/build-local-package.sh

clean:
	rm -rf dist
	rm -f packaging/arch/*.zst packaging/arch/*.tar.gz
