# data-raw/

不変（immutable）の生データを置く。一度保存したら原則として編集しない。

- このディレクトリの中身は `.gitignore` で追跡対象外（大容量・再配布不可・認証付きデータを想定）
- 例外として、テンプレート同梱の動作確認用 `example/` と `.gitkeep`・本 README・`PROVENANCE.md` のみ追跡する
- 公開データは取得スクリプト（`R/` の `read_*()` / `download_*()` 等）で再現可能にする
- ライセンスデータ・認証情報はコミットしない。バイトを共有できないファイルでも、**sha256 とメタデータは [PROVENANCE.md](PROVENANCE.md) にコミットする**

各ファイルの由来・sha256・再導出経路は [PROVENANCE.md](PROVENANCE.md) に記録する。読み込み時の sha256 検証は `R/data_provenance.R` の `verify_provenance()`（`_targets.R` の `format = "file"` ターゲットに挟む）。

実プロジェクトでは `example/` を削除し、自分の生データ取得方針をここに記述する。
