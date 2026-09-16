#!/usr/bin/env bash
# shellcheck shell=bash
# srcdir, pkgdir, pkgname, and pkgver are supplied by makepkg.

arch_normalize_source_tree() {
	local expected="${srcdir}/${pkgname}-${pkgver}"
	local -a roots=()

	while IFS= read -r -d '' root; do
		roots+=("$root")
	done < <(find "$srcdir" -mindepth 1 -maxdepth 1 -type d -print0)

	if (( ${#roots[@]} != 1 )); then
		printf 'error: expected exactly one extracted source directory in %s\n' "$srcdir" >&2
		return 1
	fi

	if [[ "${roots[0]}" != "$expected" ]]; then
		[[ ! -e "$expected" ]] || {
			printf 'error: source destination already exists: %s\n' "$expected" >&2
			return 1
		}
		mv -- "${roots[0]}" "$expected"
	fi
}

arch_check_telemetry_payload() {
	local source_root="${srcdir}/${pkgname}-${pkgver}"
	local script

	test -x "${source_root}/src/usr/bin/argvus-widget-telemetry-toggle"
	test -f "${source_root}/src/usr/share/argvus/widget-telemetry/config/argvus-widget-telemetry.jsonc"
	test -f "${source_root}/src/usr/share/argvus/widget-telemetry/config/argvus-widget-telemetry.css"
	for script in "${source_root}/src/usr/bin/argvus-widget-telemetry-toggle" "${source_root}"/src/usr/share/argvus/widget-telemetry/sh/*.sh; do
		bash -n "$script"
	done
}

arch_package_telemetry_payload() {
	local source_root="${srcdir}/${pkgname}-${pkgver}"

	install -dm755 "${pkgdir}/usr"
	cp -a "${source_root}/src/usr/." "${pkgdir}/usr/"
	find "${pkgdir}/usr/share/argvus/widget-telemetry/sh" -type f -name '*.sh' -exec chmod 755 {} +
	install -Dm644 "${source_root}/LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}

