#!/bin/sh
envsubst '${WEB_HOST} ${WEB_PORT} ${API_HOST} ${API_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/conf.d/default.conf

cat /etc/nginx/conf.d/default.conf
exec nginx -g 'daemon off;'
# 建立泛用 nginx.conf.template 檔案，讀取 env 變數，寫入 default.conf 產生通用服務
# 優點很明顯，但問題其實更多
# 優點：
#  1.不需要每次都建立一個新的 conf 檔案
#  2.一個專案一個 image，各自維護
# 缺點：
#  1.泛用的 conf 其實不好設計，最後會變成複雜的條件判斷
#  2.參數過多會導致環境變數雜亂，且不易維護
#  3.簡化的 conf 或是細節設定程獨立的 conf，會變成一個專案一個 image，各自維護，registary 會有多個 image，較不易管理