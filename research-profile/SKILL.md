---
name: research-profile
description: Maintain the user's personal research portfolio (projects, papers, ideas, failures, methods, collaborators, talks, reviews, funding) as a structured wiki at ~/research-wiki-personal/. The single-page profile.md is auto-loaded into every new agent session via the host harness's documented mechanism — Claude Code uses the `@/path/to/file` import directive in CLAUDE.md, Codex CLI uses a symlink at `~/.codex/AGENTS.md` (or per-project AGENTS.md) pointing to profile.md — so the assistant always knows what the user has worked on, what is in progress, what failed and why, and which methods/code are theirs. Use this skill whenever the user wants to record a new project, log a paper draft/submission/publication/rejection, capture an idea (promising/parked/killed), document a failed attempt, update collaborator notes, log a talk or referee work (peer review they wrote OR a referee report they received on their own paper), refresh the auto-loaded profile, or get a CV-style snapshot of their own research history. Trigger when the user is recording or retrieving facts about their own past or present research, on phrases like '记一下我做的', '加进我的研究档案', '我有个新研究 idea', '这次没 work, 记一下', '我做过什么', '我之前做过 X 吗', '更新我的 profile', 'log this project', 'add to my portfolio', 'update my research profile', 'what have I worked on', 'snapshot my research', 'remember I did X'. PRECEDENCE: if the user wants forward paths on a stuck research problem rather than a record of what they have done, this is the wrong skill, use idea-pk. If the idea is for a game, use game.
---

# Research Profile Maintenance

This file is the canonical operational protocol. It is harness-neutral. The skill ships:

- This `SKILL.md` — entry for **Claude Code**.
- A sibling `AGENTS.md` — entry for **Codex CLI**, mirroring this body (Codex does not support markdown imports, so the body must be inlined in both).

If you edit one, edit the other. See `README.md` for cross-harness install.

## Why this skill exists

Memory of "what the user has worked on" should not live only in the user's head and in scattered drafts. It should be a curated, persistent artifact that:

1. Loads automatically into every new agent session, so the assistant starts with full context instead of relearning the user from scratch.
2. Captures **failures with reasons** — research's most common scarring is doing the same dead-end twice. The wiki remembers so the user doesn't have to.
3. Tracks the lifecycle of ideas (promising → in-progress → published, or → parked → killed) instead of letting them die quietly in notebook margins.

This is **not** a personality-simulation skill. This is the **factual record** of what the user has done. The two complement: persona for *how* they think, profile for *what* they have done.

## Wiki location

**Resolution order on every invocation:**

1. `RESEARCH_PROFILE_PATH` environment variable, if set.
2. The path inside `~/.research-profile-path` if that file exists (single line, absolute path).
3. Default: `~/research-wiki-personal/`.

This wiki is **private**: unpublished ideas, embargoed results, frank collaborator notes. Treat the path with the same care as a notebook. Recommend a local-or-private-remote git repo, never a public one.

If the wiki directory does not exist, ask before creating.

## The auto-load mechanism

The single most important file is `<wiki>/profile.md` — a one-page summary structured to fit in <2k tokens. profile.md is auto-loaded into every session via your harness's documented import mechanism.

### On Claude Code (uses `@import`)

Claude Code supports the `@/absolute/path/to/file.md` import directive in CLAUDE.md files (user-level `~/.claude/CLAUDE.md`, project-level `<project>/CLAUDE.md`, or local-only `<project>/CLAUDE.local.md`). To wire profile.md for auto-load:

1. Open `~/.claude/CLAUDE.md` (creates if absent) for user-wide auto-load, OR `<project>/CLAUDE.md` for project-scoped.
2. Append a single line:
   ```
   @{{WIKI_ABSOLUTE_PATH}}/profile.md
   ```
   Replace `{{WIKI_ABSOLUTE_PATH}}` with the resolved absolute path of the wiki (e.g., `/Users/alice/research-wiki-personal`). The line must contain no `{{...}}` markers when written.
3. The first time Claude Code starts a session that triggers this import, it shows an external-import approval dialog. Approve once; the approval persists.
4. From then on: every new Claude Code session in the matching scope has profile.md content in context at session start.

### On Codex CLI (uses `~/.codex/AGENTS.md` symlink)

Codex CLI does not support `@import` (open issue [openai/codex#17401](https://github.com/openai/codex/issues/17401)). The reliable equivalent uses Codex's documented global agent doc directly.

**Recommended (global, loads in every Codex session):**

1. Symlink `~/.codex/AGENTS.md` to your profile.md:
   ```bash
   ln -sfn {{WIKI_ABSOLUTE_PATH}}/profile.md ~/.codex/AGENTS.md
   ```
   Replace `{{WIKI_ABSOLUTE_PATH}}` with the resolved absolute wiki path. The actual command must contain no `{{...}}` markers.
2. **If `~/.codex/AGENTS.md` already exists**: this symlink replaces it. Either:
   - Merge your existing global preferences into profile.md's "Working preferences" section first (single source of truth), then symlink. Recommended.
   - Or use the per-project pattern below instead.

**Per-project alternative (loads only in projects you opt in to):**

1. In each research project where you want profile.md loaded:
   ```bash
   cd <project> && ln -sfn {{WIKI_ABSOLUTE_PATH}}/profile.md AGENTS.md
   ```
   This shadows any existing project AGENTS.md (same trade-off as global). Use this pattern if you want profile.md loaded only in research-relevant projects (better privacy for users with many non-research projects).

**Why NOT `project_doc_fallback_filenames` + `~/.codex/profile.md`:** Codex's fallback-filename mechanism only checks alternate names at directories *in the project walk path* (project root → cwd), never at `~/.codex/`. A symlink at `~/.codex/profile.md` is never loaded. (Verified against [Codex docs](https://developers.openai.com/codex/guides/agents-md) and [source](https://github.com/openai/codex/blob/main/codex-rs/core/src/project_doc.rs).)

### Dual-harness users

If the user runs both Claude Code and Codex, both harnesses end up pointed at the same canonical `<wiki>/profile.md` — Claude Code via `@/path` reference, Codex via `~/.codex/AGENTS.md` symlink. After every `update-profile` operation the new content is live in both harnesses with no extra step.

### Verifying it worked

Start a fresh session and ask "what do you know about my research?". The agent should recite the contents of profile.md.

If not:
- **Claude Code**: confirm `~/.claude/CLAUDE.md` (or the relevant scope) contains the `@/abs/path` line, the path is absolute, the file exists, and the external-import dialog was approved (re-trigger by editing CLAUDE.md).
- **Codex**: confirm `~/.codex/AGENTS.md` resolves to your profile.md (`ls -l ~/.codex/AGENTS.md` should show the symlink target). Run `codex --version` to confirm a recent build.

## Wiki layout

```
<wiki>/
├── CLAUDE.md / AGENTS.md      # per-wiki schema and personal style overrides
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
├── snapshots/                 # CV-style export reports (gitignored if private)
└── funding/
```

**Incoming referee reports on the user's own paper** belong as a `## Reviewer N` sub-section inside the relevant `papers/<status>/<slug>.md`, NOT in `reviews/`. The `reviews/` directory is for peer reviews the user has written for other people's papers.

Every non-profile page has frontmatter:

```yaml
---
type: project | paper | idea | failure | method | collaborator | talk | review | funding
status: <type-specific; see per-page schemas below>   # e.g. active|paused|done for project
created: YYYY-MM-DD
last_updated: YYYY-MM-DD
sensitivity: public | private | embargoed   # default private
related: [[other-page]]
literature: [[../research-wiki/sources/<paper>]]   # cross-link into the literature-wiki
---
```

## Per-page schemas

### project (active | paused | done)
- Path: `projects/<status>/<slug>.md`
- Required body sections: `## Goal`, `## Methods used`, `## Current state`, `## Code/repo`, `## Collaborators`, `## Related literature` (links into research-wiki).
- Affects profile.md: yes, if status=active.

### paper (published | submitted | drafts | rejected)
- Path: `papers/<status>/<slug>.md` (public-shape) **plus optional** `papers/<status>/<slug>.private.md` (sensitive content, auto-gitignored by `*.private.md` rule).
- Required body sections in `<slug>.md`: `## Title and authors`, `## Target/published venue`, `## Key claim`, `## Key figures`, `## TeX repo`, `## Status timeline`. This file is safe to commit to a private remote.
- Sensitive content goes in `<slug>.private.md`: incoming referee reports (as `## Reviewer N` sub-sections), response-to-referee drafts, embargoed correspondence. Cross-link from the public `<slug>.md` via a `## Private notes` line: `See [[<slug>.private]] for embargoed reviewer reports.`
- Affects profile.md: yes if status=published (last 24 months) or status=submitted. profile.md only references the public `<slug>.md`, never the `.private.md`.

### idea (promising | parked | killed)
- Path: `ideas/<status>/<slug>.md`
- Required body sections: `## Seed thought`, `## Why promising` or `## Why parked` or `## Why killed`, `## What would unblock it`, `## Relevant literature`.
- **Killed ideas must include a `## Why killed` section.** This is the single highest-value field for future AI context: it prevents the agent from suggesting paths the user has already burned.
- Affects profile.md: killed ideas are surfaced under "Strong opinions / dead ends".

### failure
- Path: `failures/<slug>.md`
- Required body sections: `## What was tried`, `## Why it should have worked`, `## What actually happened`, `## What was ruled out`, `## Conditions that might revive it`.
- Affects profile.md: top 5–10 most informative are surfaced.

### method (mine)
- Path: `methods-mine/<slug>.md`
- Required frontmatter extras: `language`, `code_repo`, `license`.
- Required body sections: `## What it does`, `## Key API surface`, `## Gotchas`, `## Papers that use it`.
- Affects profile.md: yes, all active/maintained methods.

### collaborator
- Path: `collaborators/<slug>.md`
- Required frontmatter extras: `role: close | occasional | past`, `institution`, `expertise: [tags]`, `sensitivity: private` (default for collaborator pages).
- Required body sections: `## How we met`, `## Common projects`, `## Communication preferences`. Optional `## Frank notes` (gated by sensitivity).
- Affects profile.md: surfaced under "Active collaborators" if role=close.

### talk
- Path: `talks/<YYYY>-<slug>.md`
- Required frontmatter extras: `venue`, `date: YYYY-MM-DD`, `audience_level`, `public_url` (if recorded/public).
- Required body sections: `## Topic`, `## Key slides/figures`, `## What I'd change next time`.
- Affects profile.md: no by default.

### review (outgoing — peer review the user wrote)
- Path: `reviews/<YYYY>-<slug>.md`
- Required frontmatter extras: `journal`, `decision_recommended`, `paper_doi`, `anonymity: blind | signed`, `sensitivity: embargoed` (default).
- Required body sections: `## Paper summary`, `## My verdict`, `## Key concerns`, `## Lessons`.
- **Treat as embargoed indefinitely** — referee privilege.
- Affects profile.md: no.

### funding
- Path: `funding/<YYYY>-<slug>.md`
- Required frontmatter extras: `agency`, `status: submitted | awarded | rejected`, `amount`, `period`, `role: PI | co-PI | collaborator`.
- Required body sections: `## Project summary`, `## Key claims`, `## Deadlines`.
- Affects profile.md: only if status=awarded.

## Operations

### 1. `init` — first-time setup

Trigger: skill invoked but the wiki directory does not exist, or user explicitly asks to set up.

This is a privileged-write operation: it creates files in $HOME and modifies harness config. Each side effect is gated by an explicit confirmation step. **Do not skip the gates.**

**Step 1: Resolve and confirm wiki path.**
- Resolve via env var → `~/.research-profile-path` → default. Show the resolved absolute path.
- Ask: `Create wiki at <resolved>? [y/N]`.
- Stop if no.

**Step 2: Create directory skeleton.**
- Show what will be created (top-level directories from the layout above plus `templates/.gitignore` copied to `<wiki>/.gitignore`).
- Ask: `Create these directories and copy templates? [y/N]`.
- On yes: create directory tree, copy `templates/profile.md` to `<wiki>/profile.md` (with placeholders intact for the user to fill), copy `templates/.gitignore` to `<wiki>/.gitignore`, create empty `index.md` and `log.md`.
- Run `git init` in `<wiki>/`.

**Step 3: Wire auto-load (harness-detected, with idempotency).**
- Detect harness presence: `~/.claude/` exists → Claude Code; `~/.codex/` exists → Codex; both → ask which to wire (or both).
- For **Claude Code**:
  - Compute the import line: `@<resolved-absolute-path>/profile.md`.
  - **Idempotency check:** if `~/.claude/CLAUDE.md` already contains that exact line (`grep -Fxq` it), report "already wired" and skip the append. Otherwise show the diff and ask: `Append this import to ~/.claude/CLAUDE.md? [y/N]`.
  - On yes: append. Tell the user the next session shows an external-import approval dialog that needs accepting.
- For **Codex**:
  - Inspect `~/.codex/AGENTS.md`:
    - **Absent**: no conflict; show the symlink command and proceed on confirmation.
    - **Already a symlink to the same target** (`readlink ~/.codex/AGENTS.md` matches the resolved profile.md): report "already wired" and skip.
    - **Symlink to a different target**: warn and ask before overwriting.
    - **Regular file with content**: warn the user this would replace their existing global Codex doc. Offer: (a) cancel and use the per-project pattern instead, (b) merge the existing content into profile.md's "Working preferences" section first then symlink, (c) overwrite with a `.bak` backup (`mv ~/.codex/AGENTS.md ~/.codex/AGENTS.md.bak`).
  - Apply with: `ln -sfn <resolved>/profile.md ~/.codex/AGENTS.md` (the `-fn` flags make this idempotent: `-f` forces overwrite, `-n` does not deref an existing symlink).

**Step 4: Idempotent re-init.**
- If `<wiki>/profile.md` already exists when init is invoked, skip Steps 1–2 (do not overwrite the user's existing profile). Run only Step 3 with the idempotency checks above. This lets the user re-run init to add a second harness or fix broken wiring without losing data.

**Step 5: Recommend next.**
- Suggest setting a private remote (`git remote add origin <private-url>`).
- Suggest opening `<wiki>/profile.md` to fill placeholders.
- Remind the user that `<wiki>/.gitignore` was created with sensible defaults; review and adjust.

### 2. `log` — capture a new entry

Trigger: "记一下", "加进档案", "log this", "我有个 (research) idea", "这个没 work".

Flow:
1. Identify entry type from user phrasing. If ambiguous, ask once.
2. Create the page at the path specified by its schema (above), with all required frontmatter and body sections present (sections may be sparse on first creation).
3. Append a one-line entry to `log.md`: `## [YYYY-MM-DD] log | <type> | <slug> | <one-line>`.
4. Update `index.md`.
5. Ask: `Should profile.md be refreshed? [y/N]` if the new entry could affect the auto-loaded summary (per the "Affects profile.md" line in each schema).

### 3. `update-profile` — refresh the auto-loaded one-pager

Trigger: explicit, or after a paper is published, a project moves status, an idea is killed, or after every ~5 logs.

Flow:
1. Read all `projects/active/`, `papers/published/` (last 24 months), `papers/submitted/`, `methods-mine/` (active/maintained), `failures/` (curate top 5–10 most informative), `collaborators/` (role=close).
2. Rewrite `profile.md` from scratch (it is short enough that incremental edits are not worth the complexity). Keep under 2k tokens.
3. Show diff. Ask: `Save updated profile.md? [y/N]`.
4. On yes: save. The change is live for the next session (Claude Code re-imports; Codex re-walks the fallback file).

### 4. `snapshot` — CV-style export

Trigger: "总结一下我做了什么", "give me a CV summary", "what have I worked on this year".

Flow: read the wiki, produce a markdown report grouped by year — publications, talks, funded projects, key results. Read-only on the wiki. Optionally save to `snapshots/YYYY-MM-DD-<scope>.md` if the user wants it preserved (snapshots/ is in the default `.gitignore` since CV-grade summaries change frequently).

### 5. `lint` — health check

Trigger: explicit, or suggest after every ~20 logs.

Check for:
- Active projects with no update in 90+ days — prompt: still active, or move to `paused/`?
- Papers in `submitted/` for >120 days — flag for status check.
- Ideas in `promising/` for >180 days with no movement — propose `parked/` or `killed/`.
- Cross-links into the literature-wiki that point to non-existent pages.
- `profile.md` `last_updated` more than 60 days old — propose `update-profile`.
- Pages where required schema sections are missing.

## Working principles

- **Privacy and the model round-trip.** Every session start sends `profile.md` content to the model provider — that is the cost of auto-load. Keep `profile.md` itself free of embargo-sensitive specifics; put deep details in subpages (which are read on demand and only when the user mentions the topic). Subpages with `sensitivity: embargoed` should never be quoted into outputs that could leak (chat with non-private MCPs, public artifacts, etc.) without explicit user OK.
- **Capture, don't curate, on the way in.** When the user says "我有个 idea", write it down rough. Polish only on `update-profile` cycles.
- **Failures are first-class.** A `failures/` page is as valuable as a published paper for future AI context — it prevents the agent from suggesting paths the user already burned.
- **Cross-link into the literature-wiki** when it exists. The two together are far more powerful than either alone.
- **Read the wiki's `CLAUDE.md` / `AGENTS.md` first** for personal style overrides.

## Detail on schema and workflows

The schemas above are the contract. `templates/profile.md` is the canonical starter for the auto-loaded one-pager. `templates/.gitignore` is the privacy default. For extended schemas or operations workflows, see `references/` if present (the skill ships minimal until real workflows surface real needs).
