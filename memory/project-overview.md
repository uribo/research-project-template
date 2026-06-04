---
name: project-overview
description: プロジェクトの目的・構成・技術スタック
type: project
updated: {{DATE}}
---

# {{PROJECT_NAME}} — Overview

**Why:** {{PROJECT_DESCRIPTION}}

## 技術スタック

- R / tidyverse、`targets`（パイプライン）、`renv`（依存管理）、Quarto（ノート・原稿）
- Claude Code 統合（air/renv hooks、memory、prompts）

## 構成

- パイプライン定義: `_targets.R`、関数定義: `R/`（副作用なし）
- 探索的分析: `notes/`、原稿: `paper/`
- マイルストーン・Go/No-go ゲート: `TODO.md`

**How to apply:** 新しいタスクに着手する前にこのファイルでプロジェクトの全体像を確認する。詳細な規約は `CLAUDE.md` を参照。
