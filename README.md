# research_LLM_wiki

**English** | [中文](./README.zh.md)

A pair of cross-harness agent skills (**Claude Code** + **Codex CLI**) that turn your scientific reading and your own research history into **persistent, structured, LLM-maintained markdown wikis** instead of one-shot RAG retrievals.

Two skills, one idea. Use either alone, both together for full effect.

| Skill | What it tracks | Auto-loads? |
|---|---|---|
| **[literature-wiki](./literature-wiki/)** | Field-level knowledge: every paper you read, with cross-cutting entity / method / system / observable / debate pages | No — invoked when ingesting / querying / linting |
| **[research-profile](./research-profile/)** | Your own research portfolio: projects, papers, ideas, **failures**, methods you own, collaborators, talks, reviews, funding | **Yes** — `profile.md` auto-loads into every new session |

## The idea

Most LLM-document workflows are RAG: every question re-discovers knowledge from raw PDFs. Nothing accumulates. After reading 50 papers on a topic over six months, your assistant still answers the next question by reading fragments of three random PDFs and stitching them together. The synthesis you spent months building lives only in your head.

These skills implement a different pattern, articulated by [Andrej Karpathy in his "LLM Wiki" gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f):

> Instead of just retrieving from raw documents at query time, the LLM **incrementally builds and maintains a persistent wiki** — a structured, interlinked collection of markdown files that sits between you and the raw sources.

You curate sources and ask questions. The LLM does the bookkeeping: summarizing, cross-referencing, filing, contradiction-spotting. The wiki is the compiled artifact, kept current as new sources arrive, never rediscovered from scratch.

This repository applies that pattern to scientific research, in two complementary scopes.

## Why two skills

Same compounding-knowledge mechanism, different scope and privacy posture:

- **literature-wiki** is about the *field*. Public-knowledge sources, public-grade pages, can be browsed and even shared. Cross-link to anyone else's literature wiki.
- **research-profile** is about *you*. Unpublished ideas, failed attempts, embargoed referee reports, frank collaborator notes. Strictly private. Auto-loaded into every session so the assistant never starts cold on who you are and what you've done.

They cross-link: papers in your portfolio link to the field-level pages they cite or extend. Together they give an assistant the same situated awareness a long-term collaborator would have, with none of the re-explanation cost on every session.

## Quick start

Each skill has its own README with full install instructions:

- [literature-wiki/README.md](./literature-wiki/README.md) — install, configuration, daily use
- [research-profile/README.md](./research-profile/README.md) — install, auto-load wiring, privacy hardening

Both skills work standalone and on either harness. The combined experience (literature wiki + personal profile + cross-links) is the strongest, but you can adopt them incrementally.

## Cross-harness support

Each skill ships:

- `SKILL.md` — Claude Code entry (with YAML frontmatter for the trigger system)
- `AGENTS.md` — Codex CLI entry (no frontmatter, Codex-flavored)

The two contain the same operational protocol but are kept in sync by hand because [Codex does not yet support markdown imports](https://github.com/openai/codex/issues/17401). If you contribute, edit both. If/when Codex adds an import directive, the two can collapse to one canonical body.

## Repository layout

```
research_LLM_wiki/
├── README.md                  # this file
├── LICENSE                    # MIT
├── .gitignore
├── literature-wiki/           # field-level knowledge wiki
│   ├── SKILL.md
│   ├── AGENTS.md
│   └── README.md
└── research-profile/          # personal research portfolio
    ├── SKILL.md
    ├── AGENTS.md
    ├── README.md
    └── templates/
        ├── profile.md         # starter for the auto-loaded one-pager
        ├── .gitignore         # privacy defaults for your wiki repo
        └── pre-commit-hook.sh # optional pre-commit guard
```

## Status

Vibe-tested by the author through dual-harness installs. No formal eval suite yet. The protocols have been through one round of independent dual-AI internal review (Claude + Codex cross-validation) before publication.

PRs welcome — particularly for:

- Formal eval suites for trigger accuracy and operation correctness
- Non-physics field defaults (the categorization tables in the READMEs include suggestions for ML / biology / history / law, but no real-world stress-testing yet)
- Additional harness support (OpenCode, Aider, Cursor) once their canonical instruction-file mechanisms stabilize
- Reference-manager integrations (Zotero, Paperpile)
- A small CLI for the `log` operation in research-profile

## Author and credit

Skill author: **Jin Lei**.

Released under MIT-equivalent terms (see [LICENSE](./LICENSE)). Use freely, no warranty, no obligation.

The underlying **LLM Wiki pattern** — persistent compounding markdown knowledge base maintained by an LLM, with the human curating sources and the LLM doing the bookkeeping — is by **Andrej Karpathy**, in his publicly shared [gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f). The gist explicitly mentions both Claude Code (CLAUDE.md) and Codex (AGENTS.md) as targets; this repository is one concrete cross-harness instantiation, scoped to scientific research. Credit for the original idea belongs upstream.

## Contributing

Open an issue or PR on GitHub. For substantive changes:

- Edit both `SKILL.md` and `AGENTS.md` of the affected skill — they mirror each other.
- Run a sanity-check on either harness before committing.
- For documentation-only changes that touch user-facing behavior, also update the skill's `README.md`.

There is currently no CI; reviewer time is the gating resource.
