# [Your Name] — Research Profile

**Affiliation:** [Institution, department, role]
**Field:** [One-line research area, e.g. "Nuclear theory", "Algebraic geometry", "Computational neuroscience"]
**Last updated:** YYYY-MM-DD
**Wiki home:** `{{WIKI_ABSOLUTE_PATH}}`

> This file is auto-loaded into every new agent session. On Claude Code via `@import` in CLAUDE.md; on Codex via `~/.codex/AGENTS.md` symlinked to this file. Keep it under ~2k tokens. For depth, link to subpages. Refresh via the `research-profile` skill's `update-profile` operation. Replace `{{WIKI_ABSOLUTE_PATH}}` above with the actual path on first save.

---

## Active research lines

<!-- Top 3–5 projects you are actively working on. One sentence each. Link to projects/active/<slug>.md for depth. -->

- **[project name]** — one-sentence goal, current state, key collaborator. → [[projects/active/<slug>]]
- **[project name]** — ...

## Recent publications (last 24 months)

<!-- First-author? | Title | Journal | one-sentence what it shows. Link to papers/<status>/<slug>.md. -->

- [YYYY] *Title*, Journal volume:page. One sentence on the result. → [[papers/published/<slug>]]

## In submission / drafts

<!-- Where you are in the writing pipeline. -->

- *Title* — target journal, current state. → [[papers/submitted/<slug>]] or [[papers/drafts/<slug>]]

## Methods and code I own

<!-- Tools you built, methods you developed, code you maintain. -->

- **[method or repo name]** — one sentence on what it does. → [[methods-mine/<slug>]]

## Strong opinions and dead ends

<!-- For AI context: things you have already tried and ruled out. Each entry prevents one future suggestion of a known dead end. -->

- Tried [X] in [YYYY]; did not work because [reason]. → [[failures/<slug>]]
- Skeptical of [approach Y] because [reason].
- Strongly prefers [method A over method B] for [reason].

## Active collaborators

- **[name]**, [institution] — what you work on together. → [[collaborators/<slug>]]

## Working preferences (for the AI)

<!-- Personal style notes you want every agent session to respect. Examples below — replace with your own. -->

- [example] No em-dashes. Use commas or semicolons in both Chinese and English.
- [example] Code reviews should focus on correctness over style; do not nitpick formatting.
- [example] Math notation preference: [single conventions you use, e.g. "Einstein summation by default"].
- [example] When debugging, prefer running a quick test over long analytical reasoning.
- [example] Direct feedback is welcome and reciprocated; skip hedging.

## Skills available

<!-- Pointers to skill protocol files the assistant should read when activating an operation. Useful on harnesses without a built-in skill loader (e.g., Codex CLI's on-demand pattern). Remove this section if your harness loads skills directly. -->

- **research-profile**: when the user wants to log a project / paper / idea / failure, update this profile, snapshot, or lint, read the protocol at `/path/to/skills/research-profile/AGENTS.md` (Codex) or `/path/to/skills/research-profile/SKILL.md` (Claude Code, usually auto-loaded by the skill system) and follow it. Replace the path with the actual install location.

---

*Sub-pages of this wiki cover individual projects, papers, ideas, failures, collaborators, talks, reviews, and funding. Browse via [[index]] or grep across the wiki directory.*
