FROM google/cloud-sdk:alpine

ENV PROMETHEUS_VERSION 2.17.2

RUN apk add --no-cache tar gcc libc-dev make ruby ruby-dev && \
   wget -O prometheus.tar.gz https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz && \
   mkdir /prometheus && \
   tar -xvf prometheus.tar.gz -C /prometheus --strip-components 1 --wildcards */promtool && \
   rm prometheus.tar.gz && \
   gcloud components install kubectl -q

RUN gem install -N yaml-lint
