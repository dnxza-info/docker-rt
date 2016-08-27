FROM dnxza/rt-preinstall:latest

MAINTAINER DNX DragoN "ratthee.jar@hotmail.com"

ENV DBRT rt4
ENV DBRTUSER rt4
ENV DBRTPASS rtpass
ENV RT_VERSION 4.4.1
ENV RT_SHA1 a3c7aa5398af4f53c947b4bee8c91cecd5beb432
  
RUN cd /usr/local/src \
  && curl -sSL "https://download.bestpractical.com/pub/rt/release/rt-${RT_VERSION}.tar.gz" -o rt.tar.gz \
  && echo "${RT_SHA1}  rt.tar.gz" | shasum -c \
  && tar -xvzf rt.tar.gz \
  && rm rt.tar.gz \
  && cd "rt-${RT_VERSION}" \
  && /usr/bin/mysqld_safe & sleep 10s \
  && echo "DROP USER 'admin'@'%';" | mysql -uroot -p$MYSQLPASS \
  && echo "GRANT ALL PRIVILEGES ON *.* TO '$DBRTUSER'@'localhost' IDENTIFIED BY '$DBRTPASS' WITH GRANT OPTION;FLUSH PRIVILEGES;" | mysql -uroot -p$MYSQLPASS \
  && ./configure \
    --enable-gd \
    --enable-graphviz \
	--with-db-database=$DBRT \
    --with-db-rt-user=$DBRTUSER \
	--with-db-rt-pass=$DBRTPASS \
  && make install \
  && /usr/bin/perl -I/opt/rt4/local/lib -I/opt/rt4/lib sbin/rt-setup-database --action init --dba-password=$MYSQLPASS

COPY apache.rt.conf /etc/apache2/sites-available/rt.conf
RUN a2dissite 000-default.conf && a2ensite rt.conf

RUN chown -R www-data:www-data /opt/rt4/var/

COPY RT_SiteConfig.pm /opt/rt4/etc/RT_SiteConfig.pm
RUN chown root:www-data /opt/rt4/etc/RT_SiteConfig.pm \
  && chmod 0640 /opt/rt4/etc/RT_SiteConfig.pm
  
# Turn on ssl
RUN a2enmod ssl fcgid && \
 a2ensite rt && \
 apachectl configtest 

VOLUME /opt/rt4

EXPOSE 443

CMD [ "/bin/bash", "/start.sh", "start" ]