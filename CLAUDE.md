# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

"Harmonix" is a personal NixOS flake configuration (a system + dotfiles repo), not an application. There is no build/test/lint tooling in the traditional sense — changes are validated by evaluating or rebuilding the NixOS system.

## Common commands

- Validate that everything still evaluates, without building anything (fastest feedback loop; catches every module/option error):
  `nix eval --raw .#nixosConfigurations.laptop.config.system.build.toplevel.drvPath`
- Dry-build without activating: `nixos-rebuild build --flake .#laptop`
- Rebuild and switch: `sudo nixos-rebuild switch --flake .#laptop`
- Format every Nix file: `nixpkgs-fmt .`
- Update flake inputs: `nix flake update`
- Generate a user's login password hash (`users/<name>/password.txt`, gitignored): `./setup.sh`

**Gotcha: flakes only see git-tracked files.** A newly created `.nix` file fails with *"Path 'x.nix' … is not tracked by Git"* until it is at least `git add`-ed (staging is enough; no commit needed). Always `git add` new modules before evaluating or rebuilding.

There is only one host: `laptop` — and `flake.nix` derives both the `nixosConfigurations` attribute name and the `hosts/<name>` path from `vars.hostName`.

## Architecture

The flake (`flake.nix`) builds the host via `nixpkgs.lib.nixosSystem` with Home Manager wired in as a NixOS module (`useGlobalPkgs`/`useUserPackages`) rather than run standalone. Config is layered as:

- `vars.nix` — **single source of truth for everything install-specific**: username, full name, email, hostname, system, and `repoPath`. Reaches NixOS modules via `specialArgs` and Home Manager modules via `extraSpecialArgs` (both set in `flake.nix`). Never hardcode a username or an absolute `/home/...` path in a module; add it here and take `vars` as a module argument.
- `hosts/laptop/configuration.nix` — host entrypoint; imports hardware config, `users/default.nix`, `modules/core/default.nix`, and `modules/system/hyprland.nix`.
- `modules/core/` — system-level NixOS modules, aggregated through `modules/core/default.nix`. Add a new system-wide concern here and register it in that `default.nix`.
- `modules/system/` — desktop-environment-level modules (`hyprland.nix`, `gnome.nix`). Only `hyprland.nix` is imported; `gnome.nix` is an unwired alternative.
- `modules/home/<name>/` — one Home Manager module per app. `users/gabpetti/home.nix` selects which are enabled.
- `users/default.nix` imports per-user NixOS account definitions (`users/<name>/config.nix`); `users/<name>/home.nix` is that user's Home Manager profile.

### Conventions

- **Option namespace is `harmonix.*`** for everything this repo defines (`harmonix.configLinks`, `harmonix.swayosd.enable`, `harmonix.virtualisation.*`). Do not introduce a second namespace.
- **Module signatures declare exactly the arguments they use**, always as a braced pattern ending in `...` — `{ pkgs, ... }:`, `{ config, lib, pkgs, vars, ... }:`, or `{ ... }:` when nothing is needed. Don't carry unused `lib`/`config`/`pkgs` args, and don't use the bare `_:` form.
- Comments explain *why*, not *what*. Don't leave commented-out code in place of deletion — git history is the archive.

### The dotfile symlink pattern

Most app configs are **not** generated into the Nix store. Instead `modules/home/config-links.nix` defines `harmonix.configLinks`, and each app module declares one line:

```nix
harmonix.configLinks."nvim" = "neovim";   # ~/.config/nvim -> modules/home/neovim/config
```

That maps an `~/.config` directory name to a module directory under `modules/home`, and the shared module turns it into an out-of-store symlink into the working tree (`vars.repoPath`). Consequences:

- Editing anything under `modules/home/<name>/config` takes effect **immediately** — no rebuild. Only changes to a module's `default.nix` (packages, services, env vars, the link itself) need `nixos-rebuild`.
- `config.lib.file.mkOutOfStoreSymlink` should appear in exactly one place (`config-links.nix`). Don't reintroduce per-module call sites.
- Because the symlink target is the checkout, the repo must live at `vars.repoPath`; move it and update that one line.

### The Quickshell shell

`modules/home/quickshell/config/harmonix` is the whole desktop shell: bar, its popups, and the application/wallpaper launcher that replaced rofi. It is split by concern, one directory per layer:

- `theme/` — `Colors` (matugen palette), `Theme` (all sizes/spacing/durations), `Icons` (Nerd Font glyphs). Nothing else hardcodes a size, colour, or codepoint.
- `services/` — singletons that own state: `Audio` (PipeWire), `Backlight`, `Power` (UPower + session actions), `SystemUsage`, `NightLight`, `Wallpapers`, `Panels` (which popup is open), `LauncherState`, `Fuzzy`.
- `components/` — generic UI pieces (`BarPill`, `BarGroup`, `BarPopup`, `ListRow`, `ValueSlider`, …).
- `bar/`, `launcher/` — the actual widgets, composed from the above.

**Each directory has its own `qmldir`, and cross-directory references use relative imports** (`import "../theme"`). There is no module-path import: `import harmonix.theme` is *not* resolvable, because the config root isn't on Qt's QML import path. A singleton also only works when it is listed in its directory's `qmldir`.

Device state comes from Quickshell's own services (PipeWire, NetworkManager, BlueZ, UPower, MPRIS, StatusNotifier) rather than from polling CLI tools; the only shell-outs left are `scripts/nightlight`, `scripts/wallpaper`, and `brightnessctl` writes.

Editing any `.qml` hot-reloads the running shell — watch `qs log --pid $(pgrep -x quickshell)` for errors. Changing `shell.qml`'s `//@ pragma UseQApplication` (needed for system-tray menus) requires `systemctl --user restart quickshell` instead.

Hyprland reaches the launcher over IPC (`qs -c harmonix ipc call launcher apps|wallpapers|toggle|close`), wired to SUPER+A and SUPER+ALT+W in `modules/home/hyprland/config/default/keybindings.lua`.

### Theming via matugen

`modules/home/matugen/config/templates/*` are Material-You templates matugen renders into `matugen-colors.*` files consumed by hyprland, quickshell, kitty, swaync, gtk3/gtk4, hyprlock, and yazi. Those generated files are gitignored — never hand-edit them; edit the template.

The quickshell template is JSON, and `harmonix/theme/Colors.qml` copies every key it recognises out of it at runtime (watching the file, so a new wallpaper re-themes the bar without a restart). Adding a colour therefore means adding it in **both** places: a key in the template and a matching `property string` in `Colors.qml`.

### Secrets

`.env` (gitignored, mode 600) holds `OPENROUTER_API_KEY` and the `EDUROAM_*` values; `.env.example` documents the expected keys and which module consumes each.

`modules/core/network.nix` passes `${vars.repoPath}/.env` to NetworkManager's `ensureProfiles.environmentFiles`. NetworkManager pipes the generated profile through `envsubst` before writing it to `/etc`, so **any** field in a profile can be a `$VAR` placeholder — which is why the eduroam identity and anonymous identity live in `.env` alongside the password rather than inline. Keep personal data and credentials out of tracked `.nix` files: they would otherwise land in both the Nix store and git history.

### Maintenance cadence

Run `nix flake update` roughly monthly, then validate with the `nix eval` command above before switching. (NixOS can do this unattended via `system.autoUpgrade`, but it is deliberately not enabled — unattended upgrades on a daily-driver laptop are left as an opt-in decision.) `nix.gc` is already automatic weekly with a 14-day retention, set in `hosts/laptop/configuration.nix`.
