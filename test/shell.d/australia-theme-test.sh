#!/bin/bash

source "$(dirname "$0")/base-test.sh"

theme="$ROOT/themes/australia"
colors="$theme/colors.toml"

[[ -f $colors ]] || fail "australia ships colors.toml"
[[ -f $theme/icons.theme ]] || fail "australia ships icons.theme"
[[ -f $theme/preview.png ]] || fail "australia ships preview.png"
[[ -d $theme/backgrounds ]] || fail "australia ships backgrounds"

grep -qx 'mode = "dark"' "$colors" || fail "australia is a dark theme"
grep -q '^accent = "#' "$colors" || fail "australia defines accent"
grep -q '^background = "#' "$colors" || fail "australia defines background"
grep -q '^foreground = "#' "$colors" || fail "australia defines foreground"
if grep -q '^cursor\s*=' "$colors"; then
  fail "australia omits the cursor token"
fi

if ! find "$theme/backgrounds" -maxdepth 1 -type f \( -name '*.webp' -o -name '*.jpg' -o -name '*.png' \) | grep -q .; then
  fail "australia ships at least one background image"
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

next="$test_tmp/home/.local/state/omarchy/current/next-theme"
mkdir -p "$next"
cp "$colors" "$next/colors.toml"

HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-theme-set-templates" || fail "australia templates render"

[[ -f $next/alacritty.toml ]] || fail "australia colors.toml renders alacritty.toml"
[[ -f $next/shell.toml ]] || fail "australia colors.toml renders shell.toml"
[[ -f $next/neovim.lua ]] || fail "australia colors.toml renders neovim.lua"

if grep -R -q '{{' "$next"; then
  fail "australia templates have no leftover placeholders" "$(grep -R '{{' "$next" || true)"
fi

grep -q '#121c2b' "$next/alacritty.toml" || fail "rendered alacritty uses australia background"
grep -q '#e8b84a' "$next/shell.toml" || fail "rendered shell uses australia accent"

pass "australia theme palette renders a complete generated theme"
