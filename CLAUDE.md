# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Claude Code plugin named `krivedko` that makes an agent respond in **Йазыг Падонкаф** (the deliberately misspelled, phonetically-exact runet register of the mid-2000s: "превед медвед", "аффтар жжот"). It rewrites the agent's prose register — greetings, verdicts, commentary — while leaving code, commands, identifiers, error strings, numbers, and URLs byte-exact. There is no build, no compiled code, no package manager, and no test runner: the repo is Markdown instructions, a JSON plugin manifest, and one shell script.

Architecture is deliberately parallel to [smixs/pohuy](https://github.com/smixs/pohuy) (skill + output style + command + hook), but the transformation differs: `pohuy` inserts idioms into normal prose, `krivedko` rewrites the orthography of the prose itself.

## Repository layout

- `skills/krivedko/SKILL.md` — the core skill: activation, persistence rules, levels, the "code is untouchable" rule, Auto-Clarity (style shuts off for safety-critical output). This is what fires on `/krivedko` or an explicit user phrase — plugin install alone does **not** turn anything on by default.
- `skills/krivedko/references/` — three files the skill reads once per session and never re-reads:
  - `orfoart.md` — generative spelling rules (аканье/иканье, «жи/ши»→«жы/шы», final consonant devoicing, «-тся»→«-ца», «я»→«йа», etc.) for mangling arbitrary words not in the dictionary
  - `slovar.md` — dictionary of canonical set-phrases ("превед медвед", "аффтар жжот", "зачот/низачот", "выпей йаду") — these are reproduced byte-exact, never regenerated from the orfoart rules
  - `sceny.md` — a five-tier verdict register plus reference example scenes
- `commands/krivedko.md` — the `/krivedko [lite|full|ultra]` slash command that activates the skill for the session.
- `output-styles/krivedko.md` — an always-on output style variant of the same rules, installed system-wide via `install.sh` (separate, explicit opt-in — not enabled by the plugin install).
- `hooks/style-reminder.sh` — a `UserPromptSubmit` hook that re-injects "Krivedko output style is active" every turn, because Claude Code only auto-reinforces its own built-in output styles, not custom ones. Without this, the register fades out over a long session.
- `install.sh` — one-shot installer that copies the output style, skill, references, and hook into `~/.claude/` and wires `outputStyle: "Krivedko"` plus the hook registration into `~/.claude/settings.json` (via a small embedded Python snippet; falls back to a `sed` no-op message if `python3` is absent).
- `.claude-plugin/plugin.json` / `marketplace.json` — plugin + marketplace manifests for `claude plugin install krivedko@kgam`.
- `evals/evals.json` — five eval prompts for `skill-creator`, covering: byte-exact error text preservation, verdicts aimed at code/bug not the user, legacy-code review register, the `DROP TABLE` Auto-Clarity guard, and staying in Russian when the input is English.

## The one rule that matters everywhere in this repo

**Style lives in chat only.** Whenever editing `SKILL.md`, `output-styles/krivedko.md`, or `commands/krivedko.md`, preserve the invariant that the style must never leak into: code blocks/inline code, commands/flags/paths, identifiers, error/log strings quoted verbatim, numbers/versions/URLs, or into commit messages, PR descriptions, and docs (those stay in plain language regardless of whether the style is active in chat). Auto-Clarity (security warnings, irreversible-operation confirmations like `DROP TABLE`/`rm -rf`/force-push, order-dependent multi-step instructions) must render with zero mangling.

Canonical dictionary forms (`slovar.md`) are copied byte-exact; only words outside that dictionary get run through the `orfoart.md` generative rules. Don't blur this distinction when editing either reference file — regenerating a canonical form "by rule" is called out in the skill as the specific failure mode to avoid.

## Working in this repo

- There's nothing to build, lint, or test in the conventional sense. Validate changes by re-reading the eval prompts in `evals/evals.json` against the updated skill text, or by actually invoking `/krivedko` in a session and checking the output against the "Verify before sending" checklist embedded in `SKILL.md` / `output-styles/krivedko.md`.
- Keep `skills/krivedko/SKILL.md`, `output-styles/krivedko.md`, and `commands/krivedko.md` in sync — they restate the same rule set (dictionary-first, orfoart-generative fallback, untouchable technical content, Auto-Clarity, levels) in three different surfaces. A rule change in one almost always needs the same change in the other two.
- Extend vocabulary/scenes by adding rows to `slovar.md` / `sceny.md` rather than editing the rule prose in `SKILL.md` — the repo's stated next step is exactly this kind of table-only extension from real 2000s-runet corpus research, without restructuring the skill.
