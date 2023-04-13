# syntax = docker/dockerfile:1.0.0-experimental
FROM redash/redash:10.0.0.b50363

USER root
RUN echo ok
RUN whoami
COPY Dockerfile /tmp
RUN apt-get update && apt-get -y install wget
RUN curl -OL https://dev.mysql.com/get/mysql-apt-config_0.8.24-1_all.deb
# dpkg -i mysql-apt-config_0.8.24-1_all.deb
# RUN apt-get -y install mysql-client
# https://dev.mysql.com/get/mysql-apt-config_0.8.24-1_all.deb
