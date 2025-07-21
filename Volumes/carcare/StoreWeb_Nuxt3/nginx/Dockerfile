FROM nginx:alpine
RUN apk add --no-cache gettext
COPY ./nginx/nginx.conf.template /etc/nginx/nginx.conf.template
COPY ./nginx/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]