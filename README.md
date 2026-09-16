# argvus-widget-telemetry

Waybar telemetry widget and supporting shell scripts for the ARGVUS desktop.

[![CI](https://github.com/argvus/argvus-widget-telemetry/actions/workflows/ci.yml/badge.svg)](https://github.com/argvus/argvus-widget-telemetry/actions/workflows/ci.yml)
[![Release](https://github.com/argvus/argvus-widget-telemetry/actions/workflows/release.yml/badge.svg)](https://github.com/argvus/argvus-widget-telemetry/actions/workflows/release.yml)
[![License](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)

This repository packages the ARGVUS Waybar telemetry widget, its theme
resources, telemetry scripts, and the state toggle command.

## Build and install

On Arch Linux or a compatible distribution:

```sh
sudo pacman -S --needed base-devel git shellcheck
make validate
make build
make install
```

`make build` creates a deterministic local source archive in
`build/artifacts/` and a package in `build/dist/`. `make install` requires
`sudo` and installs the one package found in that directory.

For package metadata only:

```sh
make validate
makepkg -p packaging/arch/ci/PKGBUILD --printsrcinfo
```

See [packaging/arch/README.md](packaging/arch/README.md) for the difference
between local and release builds.

## Documentation

- [DEVELOPMENT.md](DEVELOPMENT.md) — layout, checks, and releases
- [CONTRIBUTING.md](CONTRIBUTING.md) — contribution workflow
- [SECURITY.md](SECURITY.md) — private vulnerability reports

## License

SPDX: `GPL-3.0-only`. See [LICENSE](LICENSE).
