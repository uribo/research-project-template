# ロケール（`LC_COLLATE` / `LC_TIME`）の固定

固定するのは 2 カテゴリで、理由が違う。

`LC_COLLATE` は `sort()` / `order()` / `factor()` の水準順を決める。**非 ASCII だけの問題ではない**: C は符号点順（`"Zebra" < "apple"`）、多くのシステムロケールは大小文字非依存（`"apple" < "Zebra"`）なので、ASCII のみのデータでも順序が変わる。`dplyr::arrange()` は 1.1 以降ロケール非依存なので tidyverse 中心のコードの露出は限定的だが、`factor()` を `levels =` 無しで作ると水準順が作図の凡例・モデルの contrast・`split()` の分割順へ伝播する。

`LC_TIME` は `format()` / `strftime()` の `%b` `%B` `%a` `%A` が返す月名・曜日名を決め、**ggplot2 の日付軸ラベルの既定値**がこれを踏む。`LANG=ja_JP.UTF-8` のまま固定しないと日付軸が `Jan / Feb / Mar` ではなく `1月 / 2月 / 3月` になり、**英文原稿の図に日本語ラベルが入る**。エラーは出ず、`LANG` の違う別マシンでは別の結果になる。ただし `LC_COLLATE` と違い**parse にも効く**ので、`as.Date(x, format = "%B")` で和文の月名を読んでいるプロジェクトでは `C` ではなくその文字列のロケールに固定する。

> [!WARNING]
> **`LC_ALL` で一括指定しない。** `LC_ALL` は `LC_CTYPE` まで含めて全カテゴリを上書きする。`LC_ALL=C` の下では `area == "沖縄県"` のような比較が成立しなくなり、**該当行がエラーも警告も無く結果から消える**。クラッシュではなく行の欠落なので、テストが緑のまま通過する。`LC_COLLATE` と `LC_TIME` は個別に指定する。
>
> 2026-08-28、`23_YahAuc_centipede` で発生。上記の日付ラベル（`LC_TIME`）を直そうとして `LC_ALL=C` に手を伸ばし、Supplement 表から 3 行が脱落した。参照出力とのバイト比較でしか捕まらなかった。

**`.Rprofile` だけでは守れない。** renv は特定のファイルパースから抜けるときにロケールをリセットする（`renv:::renv_parse_impl_native()` が `defer(Sys.setlocale())` を引数なしで呼んでおり、保存値への復元ではなく `LC_ALL` を環境既定へリセットしている。同ファイルの `renv_scope_locale()` は正しく保存・復元しているので upstream の書き損じ）。したがって**リセット先そのものを `C` にする**必要がある。

| 層 | 場所 | 効く範囲 |
|---|---|---|
| 1 | `Renviron.example` → `.Renviron` の `LC_COLLATE=C` / `LC_TIME=C` | **主たる固定**。環境変数なので renv のリセット後も `C` に戻る |
| 2 | `.claude/settings.json` の `env`、`.codex/config.toml` の `set` | エージェントセッション。`R_ENVIRON_USER=/dev/null` が `./.Renviron` ごと無効化する（R は `./.Renviron` を *user* Renviron として扱う）ため、層 1 が届かない |
| 3 | `.Rprofile` 末尾の `Sys.setlocale()` | `.Renviron` もエージェント設定も無いチェックアウト。**起動時しか守れない**（セッション途中の renv 呼び出しで再び飛ぶ） |

層 3 は `renv/activate.R` を `source()` した**後**に置く。前に置くと activate に上書きされ、エラーも警告も出ないまま無効になる。

**確認方法**（新規クローン時、および renv 更新後に一度）:

```bash
Rscript -e 'Sys.getlocale("LC_COLLATE")'   # "C" と出ること
Rscript -e 'Sys.getlocale("LC_TIME")'      # "C" と出ること
```

`LC_COLLATE` が `C` 以外なら、そのプロジェクトの既存成果物はシステムロケール由来の順序を持つ。値が同じでも行順・水準順が変わり得るので、修正後に再ビルドして差分を確認する。

`LC_TIME` が `C` 以外なら、日付軸を持つ既存の図が影響を受けている可能性がある。次で実際のラベルを確認できる。

```bash
Rscript -e 'suppressMessages(library(ggplot2)); d <- data.frame(x = as.Date(c("2021-01-01", "2021-06-01")), y = 1:2); cat(ggplot_build(ggplot(d, aes(x, y)) + geom_point())$layout$panel_params[[1]]$x$get_labels(), "\n")'
```
