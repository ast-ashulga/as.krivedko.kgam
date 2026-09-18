#!/bin/sh
# style-reminder — a UserPromptSubmit hook that keeps custom output styles enforced.
#
# Claude Code injects a per-turn reminder ("<Name> output style is active.
# Remember to follow the specific guidelines for this style.") ONLY for its
# built-in styles (Proactive, Explanatory, Learning). Custom styles are placed
# in the system prompt once and never reinforced, so their voice fades in long
# sessions. This hook emits the exact same reminder line for whatever custom
# style is active (e.g. "Krivedko"), closing that gap.
#
# Install: install.sh --enforce   (or copy this file and register it under
# hooks.UserPromptSubmit in ~/.claude/settings.json)

settings="${CLAUDE_DIR:-$HOME/.claude}/settings.json"
[ -f "$settings" ] || exit 0

if command -v python3 >/dev/null 2>&1; then
  style=$(python3 -c 'import json,sys
try:
    print(json.load(open(sys.argv[1])).get("outputStyle") or "")
except Exception:
    pass' "$settings")
else
  style=$(sed -n 's/.*"outputStyle"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$settings" | head -1)
fi

# Built-ins already get this reminder from Claude Code itself.
case "$style" in
  ""|default|Proactive|Explanatory|Learning) exit 0 ;;
esac

echo "$style output style is active. Remember to follow the specific guidelines for this style."
