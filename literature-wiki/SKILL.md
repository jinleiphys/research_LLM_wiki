---
name: literature-wiki
description: Maintain a personal literature knowledge wiki — a structured, interlinked markdown knowledge base where every paper the user reads is summarized, cross-referenced, and integrated into evolving entity/method/system pages. The wiki is a persistent compounding artifact that sits between the raw PDFs and the LLM, so synthesis built up over months never has to be rediscovered. Use whenever the user wants to ingest a paper into their research notes, query their accumulated literature knowledge, find contradictions across papers they have read, lint the wiki for stale claims, or build a synthesis across multiple sources. Trigger on '加入文献wiki', '把这篇加进去', '我读完这篇了', '归档这篇', '更新文献库', '我之前看过谁的 X 工作', '我的 wiki 里有没有 X', 'ingest this paper', 'update the wiki', 'what does my wiki say about X', 'add this to my literature wiki', 'sync my notes with literature-search results'. Do NOT trigger for fresh literature discovery, reference recommendations, DOI/BibTeX lookup, or 'find me a paper on X' unless the user explicitly says 'add to wiki', 'query my wiki', 'update my notes', or 'lint the wiki'. For discovery, delegate to a literature-search skill if available; this skill files what the user has read, it does not fetch new papers.
---

# Literature Wiki Maintenance

This file is the canonical operational protocol. It is harness-neutral. The skill ships:

- This `SKILL.md` — the entry point for **Claude Code**.
- A sibling `AGENTS.md` — the entry point for **Codex CLI**, which references this same body.

Same protocol, different harness wiring. See `README.md` for install steps on each.

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

If the wiki directory does not exist, ask before creating — the user may want a different location, a private remote, or to point at an existing repo.

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
├── methods/                   # method-level pages, e.g. AMD, NCSM, lattice EFT, MCMC
├── systems/                   # system-level pages, e.g. 12C+12C, CFT, LLM scaling
├── observables/               # quantity-level pages, e.g. cross section, EOS, F1 score
├── debates/                   # explicit pages: who disagrees with whom and why
└── synthesis/                 # cross-cutting themes, working theses
```

The default category names are tuned for physical-science research. Users in non-physics fields should rename to match their domain (e.g. `concepts/`, `datasets/`, `models/`). Document the customization in `<wiki>/CLAUDE.md` or `<wiki>/AGENTS.md` (whichever your harness reads); this skill respects whichever is present.

| Field example | Suggested categories |
|---|---|
| Physics / chemistry | entities, methods, systems, observables |
| ML research | datasets, methods, models, benchmarks |
| Biology | organisms, mechanisms, pathways, assays |
| History | actors, events, sources, debates |
| Law | parties, doctrines, cases, statutes |

Frontmatter on every wiki page:

```yaml
---
type: source | entity | method | system | observable | debate | synthesis
tags: [domain-tag-1, domain-tag-2]
sources: [paper-id-1, paper-id-2]   # for non-source pages, which sources contribute
last_updated: YYYY-MM-DD
---
```

## Three operations

### 1. Ingest

Trigger: user drops a paper into `<wiki>/raw/` (or hands a DOI/arXiv ID/URL) and says "归档" / "把这篇加进去" / "ingest".

Flow:
1. **Read the source.** If only an identifier is given, fetch via the user's literature-search skill first (do not skip — anti-hallucination still applies). If no such skill is installed, fetch via WebFetch.
2. **Discuss with the user.** Surface 3–5 key takeaways and ask which to emphasize before filing. Non-skippable on first ingest of a session; brief summary suffices on later ones.
3. **Create `sources/<paper-id>.md`** with: bibliographic header, abstract in the user's words (not copy-pasted), key claims with explicit page/section refs, key numbers, figures of interest (downloaded into `raw/assets/`), and links to related wiki pages.
4. **Update relevant pages** across `entities/`, `methods/`, `systems/`, `observables/`, `debates/`. A single paper typically touches 5–15 pages (Karpathy's original gist reports 10–15 for general-purpose articles; scientific papers tend to be tighter-scoped). Add new pages where needed; do not let mentioned-but-undefined entities drift orphan.
5. **Update `index.md`** — add the new source under the right category with a one-line summary.
6. **Append to `log.md`**: `## [YYYY-MM-DD] ingest | <paper-id> | <one-line takeaway>`.
7. **Confirm** to the user which pages changed and where any contradictions surfaced.

### 2. Query

Trigger: the user asks a question that wants synthesis across the wiki rather than a fresh literature search.

Flow:
1. Read `index.md` to identify candidate pages.
2. Drill into 3–10 relevant pages. Quote with file:line references.
3. Synthesize. Be explicit about what is supported, what is contradicted, and where the wiki has gaps.
4. **If the answer was non-trivial, offer to file it back** as a new page in `synthesis/` or `debates/`. Good answers should compound, not vanish into chat history.

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

- **The user curates, the skill writes.** Do not edit pages with content that did not come from a real source or from the user's explicit input.
- **Quote with provenance.** Every non-trivial claim on a wiki page links back to a `sources/` page or an external citation, never floats free.
- **Lean over comprehensive.** A wiki that is 80% covered and the user trusts beats one that is 100% covered and they don't read.
- **Use Obsidian-style `[[wikilinks]]`** for internal references — they survive renames better than relative paths and Obsidian renders them.
- **Read the wiki's `CLAUDE.md` / `AGENTS.md` first.** Users put their personal style overrides there (preferred citation format, tag taxonomy, language conventions). The skill respects that as authoritative.

## Companion skills

This skill is most powerful when combined with:

- A **literature-search** skill that fetches papers from authoritative databases with anti-hallucination protocol. Output of literature-search becomes input to this skill via `<wiki>/raw/`. After a successful literature-search, suggest filing the new sources here if the user maintains a wiki.
- A **research-profile** skill — your *personal* research record; cross-link your own papers into this field-level wiki via markdown links.
- Any **paper-writing** skill (review-writing, journal-submission, etc.) — should query this wiki when building related-work sections.

## Detail on schema and workflows

For exact page templates (debate page, synthesis page, observable schema), frontmatter examples, and database-handshake details, see `references/schema.md` and `references/operations.md` if present. The skill ships minimal until real workflows surface real needs; create those reference files on first use when the schema decisions are concrete.
