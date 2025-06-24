#!/bin/sh
envsubst '${WEB_HOST} ${WEB_PORT} ${API_HOST} ${API_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/conf.d/default.conf

cat /etc/nginx/conf.d/default.conf
exec nginx -g 'daemon off;'