# Redmine Brand Logo

A theme-independent Redmine plugin that lets you brand the header with text, a logo image, or both — configurable via `Administration → Plugins → Redmine Brand Logo → Configure`.

## Features

- Three display modes:
  - **Text only** (Redmine default behaviour)
  - **Logo only** (hide the text, show the uploaded logo)
  - **Text and logo** (logo on the left, text on the right)
- Configurable header height (20–120 px). Logo is auto-scaled proportionally — width follows.
- Optional custom header text (overrides Redmine's `app_title`).
- Logo upload from the admin panel: PNG / JPG / GIF / SVG / WebP up to 500 KB.
- Theme-independent: injects scoped CSS into `<head>` via a Redmine hook. Works under any active theme.

## Requirements

| Name              | Version |
| ----------------- | ------- |
| Redmine           | >= 6.0  |
| Ruby              | >= 3.1  |
| Database          | Whatever Redmine itself uses (no extra tables) |

## Installation

```bash
cd /usr/share/redmine/plugins
git clone https://github.com/VirtualDirector/redmine_brand_logo.git
cd /usr/share/redmine
sudo -u www-data touch tmp/restart.txt  # or systemctl restart apache2 for Passenger-Apache setups
```

No DB migration is needed — settings live in Redmine's `Setting.plugin_redmine_brand_logo` hash. The uploaded logo file lives in `<RAILS_ROOT>/files/redmine_brand_logo/` (Redmine's standard attachments dir, so daily backups pick it up automatically).

## Configuration

Go to **Administration → Plugins → Redmine Brand Logo → Configure**.

| Setting              | Description                                              |
| -------------------- | -------------------------------------------------------- |
| Display mode         | Text only / Logo only / Text and logo                    |
| Custom header text   | Optional override (blank = Redmine default)              |
| Logo height          | Pixels (default 40). Width is proportional.              |
| Logo file            | Upload via the form. Removes previous file automatically. |

## How it works (technical)

- The plugin registers a `Redmine::Hook::ViewListener` on `view_layouts_base_html_head`.
- On every page load it composes a tiny `<style>` block based on the current settings and injects it into `<head>`.
- The logo is served by `RedmineBrandLogoController#serve` at `/redmine_brand_logo/serve`. No authentication (the logo is public, like every other header asset).
- The file is stored under `files/redmine_brand_logo/logo-<timestamp>.<ext>` — overwriting cleans up the previous file.

## Notes

- This plugin uses CSS pseudo-elements (`::before`, `::after`) to inject the brand presentation. It does NOT modify any Redmine view files via Deface or patching — pure additive CSS. Should remain compatible across Redmine minor upgrades.
- Behaviour is identical under any theme (Classic, Alternate, custom). The plugin only styles `#header h1 a`, leaving the rest of the layout to the active theme.

## License

GNU GPL v2 (consistent with Redmine itself).

## Author

[Virtual Director Kft.](https://virtualdirector.hu) — 2026.
