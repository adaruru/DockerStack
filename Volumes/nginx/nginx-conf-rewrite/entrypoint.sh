#!/bin/sh
envsubst '${WEB_HOST} ${WEB_PORT} ${API_HOST} ${API_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/conf.d/default.conf

cat /etc/nginx/conf.d/default.conf
exec nginx -g 'daemon off;'
# 建立泛用 nginx.conf.template 檔案，讀取 env 變數，寫入 default.conf 產生通用服務
# 優點：
#  1.不需要每次都建立一個新的 conf 檔案
#  2.一個專案一個 image，各自維護
# 缺點：
#  1.參數過多會導致環境變數雜亂，且不易維護
#  2.無法針對不同專案建立不同的 conf 檔案，較不彈性
#  3.一個專案一個 image，各自維護，registary 會有多個 image，較不易管理