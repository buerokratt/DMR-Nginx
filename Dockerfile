FROM nginx:1.21.6
WORKDIR /etc/nginx

COPY ./nginx .
