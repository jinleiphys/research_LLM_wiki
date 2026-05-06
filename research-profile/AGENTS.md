# Research Profile — Codex CLI entry

This is the **Codex CLI** entry for the research-profile skill. The Claude Code entry is `SKILL.md` next to this file. The two contain the same operational protocol; this file is self-contained because **Codex does not support markdown imports** ([openai/codex#17401](https://github.com/openai/codex/issues/17401)) — the body must be inlined.

> **Maintenance note:** if you edit SKILL.md, mirror the change here. Both are canonical for their respective harness.

## When to act

Activate this protocol when the user says any of:

- "记一下我做的" / "加进我的研究档案" / "我有个新研究 idea" / "这次没 work, 记一下"
- "我做过什么" / "我之前做过 X 吗" / "更新我的 profile"
- "log this project" / "add to my portfolio" / "update my research profile"
- "what have I worked on" / "snapshot my research" / "remember I did X"

**PRECEDENCE:** if the user wants forward paths on a stuck research problem (brainstorming alternative approaches, "what should I try next") rather than a *record* of what they have done, do not activate this protocol — respond as a forward-thinking advisor instead. If the user is describing a game concept (game design, game mechanics, gamification), this is also not the right protocol; respond about game design.

## Why this skill exists

Memory of "what the user has worked on" should not live only in their head and in scattered drafts. It should be a curated, persistent artifact that:

1. Loads automatically into every new agent session, so the assistant starts with full context.
2. Captures **failures with reasons** — research's most common scarring is doing the same dead-end twice.
3. Tracks idea lifecycle (promising → in-progress → published, or → parked → killed).

This is the **factual record** of what the user has done, not a personality simulator.

## Wiki location

**Resolution order on every invocation:**

1. `RESEARCH_PROFILE_PATH` env var, if set.
2. `~/.research-profile-path` (single line, absolute path).
3. Default: `~/research-wiki-personal/`.

This wiki is **private**. Treat the path with notebook-grade care. If the directory does not exist, ask before creating.

## The auto-load mechanism (Codex)

profile.md is the load-bearing file. Codex CLI does not support `@import` ([openai/codex#17401](https://github.com/openai/codex/issues/17401)), so we use Codex's documented global agent doc directly.

**Recommended (global, loads in every Codex session):**

1. Symlink `~/.codex/AGENTS.md` to your profile.md:
   ```bash
   ln -sfn {{WIKI_ABSOLUTE_PATH}}/profile.md ~/.codex/AGENTS.md
   ```
   Replace `{{WIKI_ABSOLUTE_PATH}}` with the resolved absolute wiki path. The actual command must contain no `{{...}}` markers.
2. **If `~/.codex/AGENTS.md` already exists**: this symlink replaces it. Either:
   - Merge your existing global preferences into profile.md's "Working preferences" section first (single source of truth), then symlink. Recommended.
   - Or use the per-project pattern below.

**Per-project alternative (loads only in projects you opt in to):**

1. In each research project where you want profile.md loaded:
   ```bash
   cd <project> && ln -sfn {{WIKI_ABSOLUTE_PATH}}/profile.md AGENTS.md
   ```
   This shadows any existing project AGENTS.md. Use this pattern if you want profile.md loaded only in research-relevant projects (better privacy for users with many non-research projects).

**Why NOT `project_doc_fallback_filenames` + `~/.codex/profile.md`:** Codex's fallback-filename mechanism only checks alternate names at directories *in the project walk path* (project root → cwd), never at `~/.codex/`. A symlink at `~/.codex/profile.md` is never loaded. Verified against [Codex docs](https://developers.openai.com/codex/guides/agents-md) and [source](https://github.com/openai/codex/blob/main/codex-rs/core/src/project_doc.rs).

**Cross-harness users:** if you also use Claude Code, both harnesses end up referencing the same canonical `<wiki>/profile.md` — Claude Code via `@/path` import in CLAUDE.md, Codex via `~/.codex/AGENTS.md` symlink. After every `update-profile` operation the new content is live in both with no extra step.

**Verify it worked:** `ls -l ~/.codex/AGENTS.md` should show the symlink target. Start a fresh Codex session and ask "what do you know about my research?". Codex should recite the profile contents.

## Wiki layout

```
<wiki>/
├── AGENTS.md / CLAUDE.md      # per-wiki schema and personal style overrides
├── profile.md                 # ⭐ the auto-loaded one-pager
├── index.md
├── log.md
├── projects/{active,paused,done}/
├── papers/{published,submitted,drafts,rejected}/
├── ideas/{promising,parked,killed}/
├── methods-mine/
├── failures/                  # ⭐ what didn't work and why
├── collaborators/
├── talks/
├── reviews/                   # peer reviews the user has WRITTEN (outgoing)
├── snapshots/                 # CV-style exports (gitignored if private)
└── funding/
```

Incoming referee reports on the user's own paper go as `## Reviewer N` sub-sections inside `papers/<status>/<slug>.md`, NOT in `reviews/`.

Every non-profile page has frontmatter:

```yaml
---
type: project | paper | idea | failure | method | collaborator | talk | review | funding
status: <type-specific; see per-page schemas below>
created: YYYY-MM-DD
last_updated: YYYY-MM-DD
sensitivity: public | private | embargoed
related: [[other-page]]
literature: [[../research-wiki/sources/<paper>]]
---
```

## Per-page schemas

### project (active | paused | done)
- Path: `projects/<status>/<slug>.md`
- Required body sections: `## Goal`, `## Methods used`, `## Current state`, `## Code/repo`, `## Collaborators`, `## Related literature`.
- Affects profile.md: yes if status=active.

### paper (published | submitted | drafts | rejected)
- Path: `papers/<status>/<slug>.md` (public-shape) **plus optional** `papers/<status>/<slug>.private.md` (sensitive content, auto-gitignored by `*.private.md` rule).
- Required body sections in `<slug>.md`: `## Title and authors`, `## Target/published venue`, `## Key claim`, `## Key figures`, `## TeX repo`, `## Status timeline`. Safe to commit.
- Sensitive content goes in `<slug>.private.md`: incoming referee reports (as `## Reviewer N` sub-sections), response-to-referee drafts, embargoed correspondence. Cross-link from public `<slug>.md` via `See [[<slug>.private]] for embargoed reviewer reports.`
- Affects profile.md: yes if status=published (last 24 months) or status=submitted. profile.md only references the public `<slug>.md`, never the `.private.md`.

### idea (promising | parked | killed)
- Path: `ideas/<status>/<slug>.md`
- Required body sections: `## Seed thought`, `## Why promising` or `## Why parked` or `## Why killed`, `## What would unblock it`, `## Relevant literature`.
- **Killed ideas must include a `## Why killed` section.** Highest-value field for future AI context: prevents the agent from suggesting paths the user has already burned.

### failure
- Path: `failures/<slug>.md`
- Required body sections: `## What was tried`, `## Why it should have worked`, `## What actually happened`, `## What was ruled out`, `## Conditions that might revive it`.
- Affects profile.md: top 5–10 most informative are surfaced.

### method (mine)
- Path: `methods-mine/<slug>.md`
- Frontmatter extras: `language`, `code_repo`, `license`.
- Required body sections: `## What it does`, `## Key API surface`, `## Gotchas`, `## Papers that use it`.

### collaborator
- Path: `collaborators/<slug>.md`
- Frontmatter extras: `role: close | occasional | past`, `institution`, `expertise: [tags]`, `sensitivity: private` (default).
- Required body sections: `## How we met`, `## Common projects`, `## Communication preferences`. Optional `## Frank notes` (sensitivity-gated).

### talk
- Path: `talks/<YYYY>-<slug>.md`
- Frontmatter extras: `venue`, `date: YYYY-MM-DD`, `audience_level`, `public_url`.
- Required body sections: `## Topic`, `## Key slides/figures`, `## What I'd change next time`.

### review (outgoing — peer review the user wrote)
- Path: `reviews/<YYYY>-<slug>.md`
- Frontmatter extras: `journal`, `decision_recommended`, `paper_doi`, `anonymity: blind | signed`, `sensitivity: embargoed` (default).
- Required body sections: `## Paper summary`, `## My verdict`, `## Key concerns`, `## Lessons`.
- **Treat as embargoed indefinitely** — referee privilege.

### funding
- Path: `funding/<YYYY>-<slug>.md`
- Frontmatter extras: `agency`, `status: submitted | awarded | rejected`, `amount`, `period`, `role: PI | co-PI | collaborator`.
- Required body sections: `## Project summary`, `## Key claims`, `## Deadlines`.
- Affects profile.md: only if status=awarded.

## Operations

### 1. `init` — first-time setup

Privileged operation. Each side effect is gated. Idempotent across re-runs.

1. **Resolve and confirm wiki path.** Show resolved absolute path. Ask before proceeding.
2. **Create directory skeleton.** Copy `templates/profile.md` to `<wiki>/profile.md` (placeholders intact for the user to fill), copy `templates/.gitignore` to `<wiki>/.gitignore`, create empty `index.md` and `log.md`, `git init`.
3. **Wire Codex auto-load (with idempotency):**
   - Inspect `~/.codex/AGENTS.md`:
     - Absent: proceed with `ln -sfn <resolved>/profile.md ~/.codex/AGENTS.md` after confirmation.
     - Already symlinked to the same target: report "already wired", skip.
     - Symlink to a different target: warn, ask before overwriting.
     - Regular file with content: warn (this would replace the existing global Codex doc); offer cancel / merge into profile.md / overwrite-with-`.bak`-backup.
   - Apply with `ln -sfn` flags so the operation is idempotent.
4. **Idempotent re-init.** If `<wiki>/profile.md` already exists, skip Steps 1–2 (do not overwrite). Run only Step 3 with checks above.
5. Recommend next: private remote, fill profile.md, review the `.gitignore`, optionally install the pre-commit hook from `templates/pre-commit-hook.sh`.

### 2. `log` — capture a new entry

Identify entry type, create the page per its schema, append to `log.md`, update `index.md`. Ask whether to refresh profile.md if the new entry could affect the one-pager.

### 3. `update-profile` — refresh the auto-loaded one-pager

Read curated subpages, rewrite profile.md from scratch (<2k tokens), show diff, ask before saving. Live in the next Codex session (the symlink target is read on every walk).

### 4. `snapshot` — CV-style export

Read-only synthesis grouped by year. Optionally saves to `snapshots/YYYY-MM-DD-<scope>.md` (gitignored by default).

### 5. `lint` — health check

Stale active projects, long-pending submissions, stagnant ideas, broken cross-links into the literature-wiki, missing schema sections, profile.md staleness. Output report; apply only after user reviews.

## Working principles

- **Privacy and the model round-trip.** profile.md content is sent to the model provider on every session start — that is the cost of auto-load. Keep profile.md free of embargo-sensitive specifics; put deep details in subpages. Subpages with `sensitivity: embargoed` should never be quoted into outputs that could leak (chat with non-private MCPs, public artifacts, etc.) without explicit user OK.
- **Capture, don't curate, on the way in.** Polish only on `update-profile` cycles.
- **Failures are first-class.** Failure pages prevent the agent from suggesting paths the user already burned.
- **Cross-link into the literature-wiki** when it exists.
- **Read the wiki's `AGENTS.md` / `CLAUDE.md` first** for personal style overrides.

## Codex install notes

The auto-load wiring above takes `~/.codex/AGENTS.md` for profile.md (via symlink). The **skill protocol body** (this AGENTS.md you are reading) is a separate concern. Two patterns:

- **Per-project install (recommended):** in each project where you want this skill's operations available, append this AGENTS.md to the project's AGENTS.md:
  ```bash
  cat /path/to/skills/research-profile/AGENTS.md >> <project>/AGENTS.md
  ```
  The skill protocol is then loaded whenever Codex runs in that project. profile.md auto-load (the global symlink) is independent and applies in addition.

- **On-demand (no install):** keep this AGENTS.md at its skill repository path, and add a one-line pointer in your profile.md's "Skills available" section: `research-profile: read /path/to/skills/research-profile/AGENTS.md when the user wants to record their research`. Codex reads the protocol file on demand (file-read tool) when invoking skill operations. Lower-token-budget option.

The default `project_doc_max_bytes` is 32 KiB combined across all loaded files. If your combined doc set exceeds it, raise in `~/.codex/config.toml`:

```toml
project_doc_max_bytes = 65536
```

Codex has no "trigger" mechanism the way Claude Code skills do. The "When to act" rules above shape Codex behavior in absence of explicit slash-commands.

## Detail on schema and workflows

The per-page schemas in SKILL.md are the contract. `templates/profile.md` and `templates/.gitignore` are the canonical starters. See `references/` for extensions if present.
