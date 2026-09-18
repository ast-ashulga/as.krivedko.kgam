#!/usr/bin/env bash
# Установка output style «Krivedko» для Claude Code одной командой:
#   curl -fsSL https://raw.githubusercontent.com/ast-ashulga/as.krivedko.kgam/main/install.sh | bash
#
# Это явное, ручное действие пользователя — ничего не включается само по
# себе при клонировании репозитория или установке плагина. Плагин
# (`claude plugin install krivedko@krivedko`) даёт скилл, который срабатывает
# только по команде `/krivedko` или явной фразе — уже выключен по умолчанию.
# Этот скрипт — для тех, кто хочет включить стиль навсегда как output style.
#
# Ставит:
#   ~/.claude/output-styles/krivedko.md       — постоянный тон (output style)
#   ~/.claude/skills/krivedko/                — скилл с полным словарём, орфоартом и сценами
#   ~/.claude/hooks/style-reminder.sh         — per-turn подкрепление стиля (как у родных стилей CC)
#   ~/.claude/settings.json → "outputStyle": "Krivedko" + регистрация хука
set -euo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
RAW="${RAW:-https://raw.githubusercontent.com/ast-ashulga/as.krivedko.kgam/main}"

mkdir -p "$CLAUDE_DIR/output-styles" "$CLAUDE_DIR/skills/krivedko/references" "$CLAUDE_DIR/hooks"

curl -fsSL "$RAW/output-styles/krivedko.md" -o "$CLAUDE_DIR/output-styles/krivedko.md"
curl -fsSL "$RAW/skills/krivedko/SKILL.md" -o "$CLAUDE_DIR/skills/krivedko/SKILL.md"
for f in orfoart.md slovar.md sceny.md; do
  curl -fsSL "$RAW/skills/krivedko/references/$f" -o "$CLAUDE_DIR/skills/krivedko/references/$f"
done
curl -fsSL "$RAW/hooks/style-reminder.sh" -o "$CLAUDE_DIR/hooks/style-reminder.sh"
chmod +x "$CLAUDE_DIR/hooks/style-reminder.sh"

SETTINGS="$CLAUDE_DIR/settings.json"
if command -v python3 >/dev/null 2>&1; then
  python3 - "$SETTINGS" "$CLAUDE_DIR/hooks/style-reminder.sh" <<'PY'
import json, os, sys
path, cmd = sys.argv[1], sys.argv[2]
data = {}
if os.path.exists(path):
    with open(path) as f:
        data = json.load(f)
data["outputStyle"] = "Krivedko"
hooks = data.setdefault("hooks", {}).setdefault("UserPromptSubmit", [])
if not any(h.get("command") == cmd
           for group in hooks for h in group.get("hooks", [])):
    hooks.append({"hooks": [{"type": "command", "command": cmd}]})
with open(path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY
  echo "outputStyle: Krivedko прописан в $SETTINGS (плюс per-turn хук, чтобы тон держался всю сессию)"
else
  echo "python3 не найден — включи стиль вручную: /config -> Output style -> Krivedko"
fi

echo "Готово. Перезапусти Claude Code."
