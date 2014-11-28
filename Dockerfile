FROM    debian:jessie

ENV GRAFANA_VERSION 1.9.0-rc1
ENV ELASTICSEARCH_VERSION 1.4.1
ENV INFLUXDB_VERSION 0.8.6
ENV STATSD_VERSION 0.7.2

# ---------------- #
#   Installation   #
# ---------------- #

RUN apt-get -y update \
 && apt-get -y install wget \
 && apt-get -y install nginx-light supervisor \
 && apt-get -y install nodejs \
 && apt-get -y install python-pip python-dev python-cairo \
 && apt-get -y install openjdk-7-jre \
 && rm -rf /var/lib/apt/lists/*

# Install Elasticsearch
RUN cd /tmp \
 && wget -q https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}.deb \
 && dpkg -i elasticsearch-${ELASTICSEARCH_VERSION}.deb \
 && rm -f *.deb

# Install Graphite
RUN pip install carbon whisper graphite-web 'django<1.6' django-tagging 'Twisted<12.0'
ENV GRAPHITE_ROOT /opt/graphite

# Install Grafana
RUN mkdir /var/www/grafana \
 && wget -qO- http://grafanarel.s3.amazonaws.com/grafana-${GRAFANA_VERSION}.tar.gz | tar xvz --strip-components=1 -C /var/www/grafana/

# Install InfluxDB
RUN cd /tmp \
 && wget -q http://s3.amazonaws.com/influxdb/influxdb_${INFLUXDB_VERSION}_amd64.deb \
 && dpkg -i influxdb_${INFLUXDB_VERSION}_amd64.deb

RUN mkdir /opt/statsd && cd /opt/statsd \
 && wget -qO- https://github.com/etsy/statsd/archive/v${STATSD_VERSION}.tar.gz | tar xvz --strip-components=1 -C . \
 && wget -q https://raw.githubusercontent.com/bernd/statsd-influxdb-backend/master/lib/influxdb.js


RUN cd ${GRAPHITE_ROOT} \
 && cd webapp/graphite \
 && python manage.py syncdb --noinput \
 && mv local_settings.py.example local_settings.py \
 && cd - && cd conf \
 && cp storage-schemas.conf.example storage-schemas.conf \
 && cp carbon.conf.example carbon.conf

COPY supervisord.conf /etc/supervisor/conf.d/
COPY elasticsearch.yml /etc/elasticsearch/
COPY influxdb/config.toml /etc/influxdb/config.toml
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY statsd/config.js /etc/statsd/
COPY grafana/config.js /var/www/grafana/

VOLUME /opt/graphite/storage
VOLUME /data
VOLUME /var/lib/influxdb

# ---------------- #
#   Expose Ports   #
# ---------------- #

# Grafana
EXPOSE  80

# StatsD UDP port
EXPOSE  8125/udp

# StatsD Management port
EXPOSE  8126

# InfluxDB Admin server
EXPOSE 8083

# InfluxDB HTTP API
EXPOSE 8086


# -------- #
#   Run!   #
# -------- #

CMD ["/usr/bin/supervisord", "-n"]

