#!/bin/sh
# Собирает web/index.html (один файл) из исходников в web/src.
# С аргументом-путём дополнительно пишет «тело» страницы без <!doctype> (для публикации артефактом).
cd "$(dirname "$0")"
body() {
  cat head.html
  printf '<style>\n'; cat style.css; printf '</style>\n'
  printf '<div id="root"></div>\n<script>\n'; cat data.js; printf '\n'; cat search.js; printf '\n'; cat app.js; printf '</script>\n'
}
{
  printf '<!doctype html>\n<html lang="ru">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">\n'
  printf '<style>:root{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0}img{max-width:100%%}[hidden]{display:none!important}</style>\n</head>\n<body>\n'
  body
  printf '</body>\n</html>\n'
} > ../index.html
[ -n "$1" ] && body > "$1"
exit 0
