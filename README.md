# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

R / tidyverse + `targets` + `renv` + Quarto による研究分析プロジェクト。Claude Code / Codex との協働を前提とした構成。

- プロジェクト知識・規約: [CLAUDE.md](CLAUDE.md)
- Codex 固有の規約: [AGENTS.md](AGENTS.md)
- マイルストーン・Go/No-go ゲート: [TODO.md](TODO.md)

> このリポジトリは [research-project-template](https://github.com/uribo/research-project-template) テンプレートから生成された。初回セットアップが未了の場合は [SETUP.md](SETUP.md) を参照。

## 前提ツール

| ツール | 用途 | 確認コマンド |
|---|---|---|
| R (4.6.1 基準) | 解析本体。CI（R-check）と同じ基準版。renv.lock 生成後はその記録版が正 | `Rscript --version` |
| [renv](https://rstudio.github.io/renv/) | パッケージ管理 | `Rscript -e 'packageVersion("renv")'` |
| [air](https://posit-dev.github.io/air/) | R フォーマッタ | `air --version` |
| [Quarto CLI](https://quarto.org/) | ノート・原稿レンダー | `quarto --version` |

VS Code / Positron では、ワークスペースを開くと [.vscode/extensions.json](.vscode/extensions.json) の推奨拡張（air・Quarto）の導入が提示され、[.vscode/settings.json](.vscode/settings.json) により保存時フォーマット（R: air、.qmd: Quarto）が有効になる。

## セットアップ

```bash
# 依存パッケージを復元（renv.lock がある場合）
Rscript -e 'renv::restore()'

# 初回（renv 未初期化の場合）
Rscript -e 'renv::init()'
```

## 実行

```bash
# パイプライン全体
Rscript -e 'targets::tar_make()'

# 定義の検証
Rscript -e 'targets::tar_validate()'

# テスト（非 package プロジェクト: tests/testthat/setup.R が R/ を source して実行）
Rscript tests/testthat.R

# ノート・原稿のレンダー（Quarto CLI が必要）
quarto render notes/
quarto render paper/
```

## ディレクトリ

構成と各ディレクトリの役割は [CLAUDE.md](CLAUDE.md)「ディレクトリ構成」を参照。
