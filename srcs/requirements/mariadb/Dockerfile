FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/mysql/*

RUN mkdir -p /var/run/mysqld /var/log/mysql \
    && chown -R mysql:mysql /var/run/mysqld /var/log/mysql /var/lib/mysql \
    && chmod 777 /var/run/mysqld

COPY ./conf/server.cnf /etc/mysql/mariadb.conf.d/mysqld.cnf
RUN chmod 644 /etc/mysql/mariadb.conf.d/mysqld.cnf

COPY ./tools/script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/script.sh"]