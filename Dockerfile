FROM redash/redash:10.0.0.b50363

RUN sudo apt-get update && sudo apt-get -y install wget
RUN curl -OL https://dev.mysql.com/get/mysql-apt-config_0.8.24-1_all.deb && sudo dpkg -i mysql-apt-config_0.8.24-1_all.deb
RUN sudo apt-get -y install mysql-client postgresql
# https://dev.mysql.com/get/mysql-apt-config_0.8.24-1_all.deb
