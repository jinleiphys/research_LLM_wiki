# research_LLM_wiki

[English](./README.md) | **中文**

一对跨 harness 的 agent skill（**Claude Code** + **Codex CLI**），把你的科研阅读和你自己的研究历史变成 **持久化、结构化、由 LLM 维护的 markdown wiki**，而不是每次提问都临时 RAG 检索。

两个 skill，一个想法。可以单独用，组合用效果最强。

| Skill | 它跟踪什么 | 自动加载？ |
|---|---|---|
| **[literature-wiki](./literature-wiki/)** | 领域级知识：你读过的每一篇论文，加上跨切的实体 / 方法 / 体系 / 观测量 / 争议页面 | 否——按需触发（ingest / query / lint）|
| **[research-profile](./research-profile/)** | 你自己的研究档案：项目、论文、idea、**失败案例**、你做的方法/代码、合作者、报告、审稿、基金 | **是**——`profile.md` 自动加载到每个新会话 |

## 核心想法

主流的 LLM-文档工作流是 RAG：每次提问都从原始 PDF 重新发现知识，**啥都不积累**。读了某个方向 50 篇论文半年之后，你的助手回答下一个问题时还是从随机三篇 PDF 里捞片段拼凑——你花几个月建立的综合判断只活在你自己脑子里。

这两个 skill 实现的是另一种模式，[Andrej Karpathy 的 "LLM Wiki" gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) 说得很清楚：

> 不要在查询时才从原始文档检索，而是让 LLM **逐步构建并维护一个持久化的 wiki**——结构化、互相链接的 markdown 文件集合，坐落在你和原始文献之间。

你负责选源和提问，LLM 干所有 bookkeeping：写摘要、做交叉引用、归档、抓矛盾。Wiki 是被编译出的产物，每来一篇新文献就更新一次，**不再每次重建**。

这个仓库把这个模式用在科研上，分两个互补的 scope。

## 为什么是两个 skill

同一种"知识复利"机制，两种 scope 和隐私级别：

- **literature-wiki** 关注**领域**。公开知识、公开级页面，可以浏览甚至共享。可以和别人的 literature wiki 互相 cross-link。
- **research-profile** 关注**你自己**。未发表的 idea、失败的尝试、被禁运期的审稿意见、对合作者的坦率笔记。**严格私有**。自动加载到每个会话，让助手永远不会从零开始认识你。

两者互相 cross-link：你 portfolio 里的论文链向它们引用或扩展的领域级页面。组合起来，你的助手就有了一个长期合作者级的 situational awareness——不用每次会话重新解释你是谁、做过啥。

## 快速开始

每个 skill 都有自己完整安装说明的 README：

- [literature-wiki/README.md](./literature-wiki/README.md)——安装、配置、日常用法
- [research-profile/README.md](./research-profile/README.md)——安装、auto-load 接线、隐私加固

两个 skill 都可以单独用，也都支持两个 harness。组合体验（领域 wiki + 个人 profile + 互链）最强，但你可以渐进采用。

## 跨 harness 支持

每个 skill 都打包了：

- `SKILL.md`——Claude Code 入口（带 YAML frontmatter 给触发系统用）
- `AGENTS.md`——Codex CLI 入口（无 frontmatter，Codex flavored）

两个文件包含相同的操作协议，但需要**手动同步**——因为 [Codex 还不支持 markdown import](https://github.com/openai/codex/issues/17401)。如果你 PR，记得改两边。等 Codex 加了 import 指令，两个文件就能合并成一份正典。

## 仓库结构

```
research_LLM_wiki/
├── README.md                  # 英文版（默认）
├── README.zh.md               # 本文件
├── LICENSE                    # MIT
├── .gitignore
├── literature-wiki/           # 领域级文献 wiki
│   ├── SKILL.md
│   ├── AGENTS.md
│   └── README.md
└── research-profile/          # 个人研究档案
    ├── SKILL.md
    ├── AGENTS.md
    ├── README.md
    └── templates/
        ├── profile.md         # auto-load 一页档案的起手模板
        ├── .gitignore         # 你 wiki repo 的隐私默认值
        └── pre-commit-hook.sh # 可选 pre-commit 守卫
```

## 状态

作者通过双 harness 安装做过 vibe-test，没有正式 eval suite。协议在发布前经过一轮独立的双 AI 内部 review（Claude + Codex 互相交叉验证）。

欢迎 PR，特别是这些方向：

- 触发准确率和操作正确性的正式 eval suite
- 非物理领域的默认值（README 表格里给了 ML / 生物 / 历史 / 法律的建议，但还没在真实场景压过）
- 加更多 harness 支持（OpenCode、Aider、Cursor），等它们的"正典指令文件"机制稳定下来
- 文献管理工具集成（Zotero、Paperpile）
- research-profile 的 `log` 操作的小 CLI

## 作者与归属

Skill 作者：**Jin Lei**。

按 MIT 等价条款发布（见 [LICENSE](./LICENSE)）。随便用，无担保，无义务。

底层的 **LLM Wiki 模式**——由 LLM 维护的持久化 markdown 知识库，人类负责选源、LLM 负责 bookkeeping——是 **Andrej Karpathy** 的，原文在他的公开 [gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)。原 gist 明确提了 Claude Code（CLAUDE.md）和 Codex（AGENTS.md）两个目标；本仓库是一个跨 harness 的具体实现，scope 限定在科研。**原创想法的 credit 归上游**。

## 贡献

在 GitHub 上开 issue 或 PR。涉及实质改动的：

- 修改对应 skill 的 `SKILL.md` 和 `AGENTS.md` **两边**——它们互为镜像。
- 提交前在任一 harness 上跑一下 sanity check。
- 涉及用户可见行为的文档改动，同时更新对应 skill 的 `README.md`。

目前没有 CI，审阅人时间是瓶颈。
