FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/mysqld /var/log/mysql \
    && chown -R mysql:mysql /var/run/mysqld /var/log/mysql /var/lib/mysql \
    && chmod 777 /var/run/mysqld

COPY ./conf/server.cnf /etc/mysql/mariadb.conf.d/server.cnf
RUN chmod 644 /etc/mysql/mariadb.conf.d/server.cnf

RUN mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

COPY ./tools/script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/script.sh"]