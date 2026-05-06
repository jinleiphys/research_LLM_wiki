# Literature Wiki — Codex CLI entry

This is the **Codex CLI** entry for the literature-wiki skill. The Claude Code entry is `SKILL.md` next to this file. The two contain the same operational protocol; this file is self-contained because **Codex does not support markdown imports** (open issue [openai/codex#17401](https://github.com/openai/codex/issues/17401)) — the body must be inlined.

> **Maintenance note:** if you edit SKILL.md, mirror the change here. Both are canonical for their respective harness. The READMEs flag this for contributors.

## When to act

Activate this protocol when the user says any of:

- "加入文献wiki" / "把这篇加进去" / "我读完这篇了" / "归档这篇" / "更新文献库"
- "我之前看过谁的 X 工作" / "我的 wiki 里有没有 X"
- "ingest this paper" / "update the wiki" / "what does my wiki say about X"
- "add this to my literature wiki" / "sync my notes with literature-search results"

**Do NOT activate** for fresh literature discovery, reference recommendations, DOI/BibTeX lookup, or "find me a paper on X" unless the user explicitly says "add to wiki", "query my wiki", "update my notes", or "lint the wiki". For discovery, delegate to a literature-search tool if installed; this skill files what the user has read, it does not fetch new papers.

## Why this skill exists

Most LLM-document workflows look like RAG: every question re-discovers knowledge from raw PDFs. Nothing accumulates. For a researcher reading dozens of papers a year on related topics, this is wasted compounding.

This skill maintains a **persistent, structured wiki** of markdown files. When the user reads a new paper, the skill reads it, extracts what matters, and integrates it into existing entity/method/system pages — updating cross-references, flagging where new data contradicts old claims, strengthening the evolving synthesis. The wiki is the compiled artifact; the raw PDFs sit beside it but are not the primary lookup layer.

The user curates and asks. The skill writes and maintains.

The pattern is field-independent. It works for nuclear physics, condensed matter, ML, biology, history, law — any domain where the user accumulates papers/articles over time.

## Wiki location

**Resolution order on every invocation:**

1. `LITERATURE_WIKI_PATH` environment variable, if set.
2. The path inside `~/.literature-wiki-path` if that file exists (single line, absolute path).
3. Default: `~/research-wiki/`.

If the wiki directory does not exist, ask before creating.

## Wiki layout

```
<wiki>/
├── CLAUDE.md / AGENTS.md      # per-wiki schema mirror; user puts personal style here
├── index.md                   # content index, organized by category
├── log.md                     # chronological log of ingests/queries/lints
├── raw/                       # source PDFs/markdown, IMMUTABLE
│   └── assets/                # downloaded figures
├── sources/                   # one page per paper, summary + key numbers
├── entities/                  # authors, groups, experiments, code packages
├── methods/                   # method-level pages
├── systems/                   # system-level pages
├── observables/               # quantity-level pages
├── debates/                   # explicit pages: who disagrees with whom and why
└── synthesis/                 # cross-cutting themes, working theses
```

Default category names suit physical-science research. Other fields should rename:

| Field | Suggested categories |
|---|---|
| Physics / chemistry | entities, methods, systems, observables |
| ML research | datasets, methods, models, benchmarks |
| Biology | organisms, mechanisms, pathways, assays |
| History | actors, events, sources, debates |
| Law | parties, doctrines, cases, statutes |

Document customization in `<wiki>/AGENTS.md` (Codex) or `<wiki>/CLAUDE.md` (Claude Code).

Frontmatter on every wiki page:

```yaml
---
type: source | entity | method | system | observable | debate | synthesis
tags: [domain-tag-1, domain-tag-2]
sources: [paper-id-1, paper-id-2]
last_updated: YYYY-MM-DD
---
```

## Three operations

### 1. Ingest

Trigger: user drops a paper into `<wiki>/raw/` (or hands a DOI/arXiv ID/URL) and says "归档" / "把这篇加进去" / "ingest".

Flow:
1. **Read the source.** If only an identifier is given, fetch via the user's literature-search tool first (do not skip — anti-hallucination still applies). If no such tool, fetch via Codex's web access if available.
2. **Discuss with the user.** Surface 3–5 key takeaways and ask which to emphasize before filing. Non-skippable on first ingest of a session; brief summary suffices on later ones.
3. **Create `sources/<paper-id>.md`** with: bibliographic header, abstract in the user's words, key claims with page/section refs, key numbers, figures of interest, and links to related wiki pages.
4. **Update relevant pages** across `entities/`, `methods/`, `systems/`, `observables/`, `debates/`. A single paper typically touches 5–15 pages (Karpathy's gist reports 10–15 for general articles; scientific papers tend tighter). Add new pages where needed; do not let mentioned-but-undefined entities drift orphan.
5. **Update `index.md`** with a one-line summary of the new source.
6. **Append to `log.md`**: `## [YYYY-MM-DD] ingest | <paper-id> | <one-line takeaway>`.
7. **Confirm** which pages changed and where contradictions surfaced.

### 2. Query

Trigger: user asks a question wanting wiki synthesis rather than fresh literature search.

Flow:
1. Read `index.md` to find candidate pages.
2. Drill into 3–10 relevant pages with file:line citations.
3. Synthesize. Flag what is supported, what is contradicted, where the wiki has gaps.
4. **If non-trivial, offer to file the answer** as a new page in `synthesis/` or `debates/`. Good answers should compound.

### 3. Lint

Trigger: explicit request, or after every ~10 ingests, suggest one.

Check for:
- **Contradictions** between pages — flag with `[CONTRADICTS sources/X.md]` markers and create a `debates/` entry.
- **Stale claims** — pages that cite old sources where newer ones supersede.
- **Orphans** — pages no other page links to.
- **Missing entities** — concepts mentioned across multiple sources but lacking their own page.
- **Frontmatter drift** — wrong type tags, missing dates.
- **Suggested next reads** — gaps the wiki cannot answer; surface as questions for the next literature-search run.

Output: a markdown report. Apply fixes only after the user reviews.

## Working principles

- **The user curates, the skill writes.** Pages contain only content from real sources or the user's explicit input.
- **Quote with provenance.** Every non-trivial claim links back to a `sources/` page or external citation.
- **Lean over comprehensive.** 80% covered and trusted beats 100% covered and unread.
- **Use Obsidian-style `[[wikilinks]]`** for internal references; they survive renames.
- **Read the wiki's `AGENTS.md` / `CLAUDE.md` first** for personal style overrides.

## Companion skills

- A **literature-search** skill for database fetches with anti-hallucination protocol. Output of literature-search is input here.
- A **research-profile** skill — your *personal* research record; cross-link your own papers into this field-level wiki.
- Any **paper-writing** skill — should query this wiki for related-work sections.

## Codex install notes

- Append this file's contents (or a relevant subset) to `~/.codex/AGENTS.md` for global use, or to your project's AGENTS.md for project-local use. Codex auto-loads AGENTS.md from project root walking down to cwd.
- The default `project_doc_max_bytes` is 32 KiB combined. If you also have other AGENTS.md content, raise it in `~/.codex/config.toml`:
  ```toml
  project_doc_max_bytes = 65536
  ```
- Codex does not have a "trigger" mechanism the way Claude Code skills do. The "When to act" section above is read by Codex on every session and shapes its behavior; the user should still invoke this protocol explicitly when intent is ambiguous.
