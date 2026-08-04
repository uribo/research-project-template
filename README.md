# {{PROJECT_NAME}}

[![R-check](https://github.com/{{GITHUB_REPO}}/actions/workflows/R-check.yaml/badge.svg)](https://github.com/{{GITHUB_REPO}}/actions/workflows/R-check.yaml)
[![renv-update](https://github.com/{{GITHUB_REPO}}/actions/workflows/renv-update.yaml/badge.svg)](https://github.com/{{GITHUB_REPO}}/actions/workflows/renv-update.yaml)

<!-- Optional static badges. Uncomment and fill in what applies; delete the rest.
     The Obsidian link is author-local (it resolves only on a machine with that
     vault) — keep it out of repositories shared with collaborators.
[![Grant: GRANT_NAME](https://img.shields.io/badge/Grant-GRANT__NAME-blue)]()
[![Period: START–END](https://img.shields.io/badge/Period-YYYY.MM--YYYY.MM-green)]()
[![Obsidian Notes](https://img.shields.io/badge/Obsidian-PROJECT__SLUG-green)](obsidian://open?vault=VAULT&file=research%2FPROJECT_SLUG)
-->

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

## CI

| ワークフロー | 起動 | 内容 |
|---|---|---|
| [R-check](.github/workflows/R-check.yaml) | push / pull request | `targets::tar_validate()` と `tests/testthat.R` |
| [renv-update](.github/workflows/renv-update.yaml) | 日次起動（リポジトリ名のハッシュで割り当てた週 1 回の曜日にのみ実行）・`workflow_dispatch` | `renv::update()` の結果を `automation/renv-update` ブランチの PR で提案する |

### 初回に必要なリポジトリ設定

`renv-update` は `GITHUB_TOKEN` で PR を作成するため、**リポジトリ設定で Actions の PR 作成を許可する**。Settings → Actions → General → Workflow permissions の **Allow GitHub Actions to create and approve pull requests** を有効化するか、CLI で:

```bash
gh api -X PUT /repos/{{GITHUB_REPO}}/actions/permissions/workflow \
  -f default_workflow_permissions=read \
  -F can_approve_pull_request_reviews=true
```

`default_workflow_permissions` は `read` のままでよい。ワークフローが `permissions: contents: write` を宣言しており、ワークフロー単位で既定より広い権限を要求できるため。

未設定のままだと、`renv::restore()` / `renv::update()` は成功したうえで**最後の `gh pr create` だけが落ちる**。ワークフロー冒頭の `permissions: pull-requests: write` はこのリポジトリ設定を上書きできない:

```
pull request create failed: GraphQL: GitHub Actions is not permitted to create or approve pull requests (createPullRequest)
```

このとき push 自体は済んでいるため、**PR の無い `automation/renv-update` ブランチが残る**。設定を有効化したうえで `gh workflow run renv-update.yaml` を手動実行すれば PR が作られる。

## ディレクトリ

構成と各ディレクトリの役割は [CLAUDE.md](CLAUDE.md)「ディレクトリ構成」を参照。
