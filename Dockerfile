FROM nginx:1.21.6
WORKDIR /etc/nginx

RUN apt update
RUN apt install jq -y
RUN apt install cron -y

COPY ./docker-entrypoint.d /docker-entrypoint.d
RUN chmod 700 /docker-entrypoint.d/init-participants.sh

COPY ./nginx .
RUN chmod 700 ./sh/reload-participants.sh
RUN chmod 700 ./cron/reload-participants-cron
RUN crontab ./cron/reload-participants-cron

ENV CENTOPS_HOST=https://host.docker.internal:7191
