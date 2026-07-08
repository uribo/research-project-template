# data-raw provenance

不変（immutable）の生データ 1 ファイルにつき 1 エントリを記録する。`file` と
`sha256` は機械可読な検証用（`R/data_provenance.R` の `verify_provenance()` が読む）。
残りは人間可読な由来（どこから・いつ・どう取得したか・ライセンス）。

- **凍結（バイトコピー）は最終手段**。まず不変・引用可能な正典（版付き DOI、タグ付き
  リリース、commit SHA、CRAN 版＋SHA）に pin し、都度再取得する経路を残す
- どの手段でも**正典からの再導出スクリプト（provenance）を必ず残す**
- ライセンスデータ・認証付きデータはコミットしない（`.gitignore` 済み）。この
  PROVENANCE.md には**ハッシュとメタデータだけ**をコミットし、バイトは共有しない

## Manifest

| file | sha256 | rows | source | retrieved | license | re-derivation |
|---|---|---|---|---|---|---|
| `example/penguins-sample.csv` | `71653a432f48da60de096a74221e5db85bb68a5c3ff6bd9fabd19a1645e924a3` | 12 | palmerpenguins（テンプレート同梱の動作確認用サンプル） | 2026-07-08 | CC0 | `palmerpenguins::penguins` から抜粋（実プロジェクトでは削除） |

<!--
実プロジェクトのエントリ雛形（sha256 は `R/data_provenance.R` の
`sha256_file()` か `shasum -a 256 <file>` で算出）:

| `subdir/your-data.csv` | `<sha256>` | <n> | <正典 URL / DOI / repo@SHA> | <YYYY-MM-DD> | <ライセンス> | <取得スクリプトへのパス> |
-->
