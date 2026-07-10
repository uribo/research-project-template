-- notes/ 用リンク書き換えフィルタ
--
-- 目的: ソースの .qmd では他ノートへのリンクを `.qmd` で書いておき
--       （編集・GitHub 閲覧・tar_quarto 依存解決に好都合）、
--       HTML レンダー時のみ `.qmd` を `.html` に書き換える。
--       これによりレンダー済み HTML をブラウザで開いた際、
--       リンク先が生テキスト(.qmd)ではなくレンダー済み(.html)になる。
--
-- 適用: notes/_metadata.yml の `filters:` に登録し、notes/ 配下の
--       全 .qmd に自動適用。tar_quarto の個別レンダー・手動レンダーの
--       双方で機能する。
--
-- 対象: 相対パスかつ拡張子 .qmd のローカルリンクのみ。
--       外部 URL（scheme 付き）・非 .qmd リンクは変更しない。
--       #anchor / ?query は保持する。HTML 出力時のみ動作。

function Link(el)
  if not quarto.doc.is_format("html") then
    return el
  end
  local target = el.target
  -- 外部 URL（https://, mailto: 等の scheme 付き）はスキップ
  if target:match("^%a[%w+.%-]*:") then
    return el
  end
  -- パス部分と #anchor / ?query を分離
  local path, suffix = target:match("^([^#?]*)(.*)$")
  if path and path:match("%.qmd$") then
    el.target = (path:gsub("%.qmd$", ".html")) .. suffix
  end
  return el
end
