---
name: project-status
description: 現在の進捗・直近の作業・次のステップ
type: project
updated: 2026-08-28
---

# {{PROJECT_NAME}} — Status

## 引き継ぎ（HANDOFF）

> 別のエージェント（Codex 等）や次のセッションが**この欄だけ読めば再開できる**状態を保つ。残すのは今使っている判断だけで、検討しただけの案は書かない。方針を決めた時・試行を捨てた時・検証を実行した時・セッションを終える時に更新する。

- **現在採用している方針**: 「Prompt Logging Rule」を「Delegation Brief Rule」に統一（2026-08-28）。prompts/ は Codex 向け delegation brief のみ保持。**per-task prompt logs・finish timestamps・end-of-session insights は廃止**。理由：HANDOFF との重複（2026-08-25 からの発見）、Codex が prompts/ を自動読み込みしない、prompts/ gitignored で URLs の耐久性が低い。代替：決定を支える URL は HANDOFF に決定の直脇に記録。代替案「gitignored URL record」は却下（耐久性・findability）。グローバル common-instructions.md 更新済み、codex/AGENTS.md 再生成済み（conf-macos commit）。
- **次に行う作業（1 つ）**: なし（テンプレート側は完了）。生成済みプロジェクトへの Delegation Brief Rule 波及は**任意のタイミング**で行う。既存プロジェクトは現行の Prompt Logging Rule のままでも許容する（2026-08-28 ユーザー判断）。波及するときは各 CLAUDE.md の「Prompt Logging Rule」節と `prompts/README.md` をテンプレート `81692ea` に合わせる。
- **試して失敗したこと**: prompts/ を gitignored URL record として保つ（不耐久）；HANDOFF と per-task logs の重複併行（即座に廃止決定）；prompts/*.md の force-add（2026-08-26 に amend で除去済み、auto-committer へは exclusion 指示）。
- **未確認の項目**: なし。下流プロジェクトの適用状況は追跡しない（任意波及のため）。
- **最後に実行した検証と結果**: Decision finalized. common-instructions.md → codex/AGENTS.md 再生成完了。propagation not yet started (2026-08-28).

- **現在フェーズ**: （要記入: Pre-analysis / Gate 検証 / 実装 / 執筆 …）
- **直近の作業**: （要記入）
- **次のステップ**: （要記入）
- **ブロッカー**: `TODO.md`「横断的ブロッカー」を参照

**How to apply:** セッション終了時に進捗が変化したらこのファイルを更新する。「引き継ぎ（HANDOFF）」欄は方針を決めた時・試行を捨てた時・検証を実行した時にも更新し、Codex 等へ引き継ぐときはこの欄を先に読ませる（グローバル指示「Codex への委任と引き継ぎ」）。
