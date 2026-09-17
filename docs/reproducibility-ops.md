# 再現性の運用（sentinel・lockfile 更新・凍結）

> `AGENTS.md`「再現性」節から分けた詳細。数値 sentinel を書くとき、renv を更新するとき、原稿を投稿するときに読む。

- **数値 reproducibility sentinel を置く**: `tar_validate()` は DAG 構造しか見ず、`renv` 更新は数値 drift を素通りさせる。主要導出値（サンプルサイズ・係数・要約統計）を許容誤差でピン留めした testthat テストを、commit 済みの小さな fixture（本番データが gitignored なら合成データ）に対して置く（雛形: `tests/testthat/test-reproducibility.R`）。`renv-update` workflow でも走り drift を PR に赤表示する。**限界**: 代表 fixture の drift 検出であって「通れば論文結果が完全再現」ではない。完全な再現確認はローカルで本番データに `tar_make()` を再走して突き合わせる
- **lockfile 更新は再ビルドの契機**: renv-update PR の merge や手動 `renv::update()` の後は `tar_make()` を回し直す。版ピン留めの対象外のパッケージ更新を `tar_outdated()` は報告しないので、**何も outdated に見えないのは「整合している」ではなく「見えていない」**。放置すると旧環境で計算されたオブジェクトがストアに残り、`tar_read()` 経由で「lockfile が主張する環境では再現できない数値」が原稿に載る。gittargets 導入プロジェクトでのスナップショットの順序は [gittargets.md](gittargets.md) を参照
- `renv-update` workflow は開発フェーズの依存衛生ツール。**原稿投稿後・査読中・出版アーカイブ後は凍結**する（as-submitted freeze）。凍結は PR を無視するのではなく `gh workflow disable renv-update` で**無効化**する。再開は `workflow_dispatch` で足りる

## 版ピン留めターゲットが必要な理由

targets は既定でパッケージ版を cue に含めない。`tar_option_set(imports)` はこのテンプレートのスタイルでは**機能しない**: 名前空間付き呼び出し（`pkg::fun()`）は自由シンボルとして追跡されず、`targets::tar_deps(coxme::coxme(x))` は `::` と `x` しか返さない（2026-08-26 実測）。survival / glmmTMB / emmeans などは名前空間単体で DAG 循環を起こす。

そのため `AGENTS.md`「targets パイプライン」の版ピン留めターゲット（`model_pkg_versions`）をブレース参照で依存させる方式を採る。版だけ上がってコード同一でも再計算が走る粗さは受け入れる。CmdStan 等の R 外バックエンドも、版をピンターゲットに含めれば同じ機構に載る。これは数値 sentinel と lockfile 更新後の再ビルド規律の代替ではなく補完。
