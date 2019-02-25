FROM ruby:2.6.1-alpine as ruby_builder
MAINTAINER Dennis-Florian Herr <herrdeflo@gmail.com>
RUN apk add --update --no-cache \
    ca-certificates \
    openssl \
    g++ \
    gcc \
    libc-dev \
    make \
    patch \
    postgresql-dev \
  && rm -rf /var/cache/apk/*

ADD peer/Gemfile /peer/Gemfile
ADD peer/Gemfile.lock /peer/Gemfile.lock

WORKDIR /peer

RUN bundle install \
  && rm /usr/local/bundle/cache/*

FROM ruby:2.6.1-alpine
RUN apk add --update --no-cache \
     ca-certificates \
     openssl \
     libstdc++ \
     postgresql-dev \
     tzdata \
     less \
     bash \
     curl \
  && rm -rf /var/cache/apk/*

ENV TZ Europe/Berlin

ADD docker-bin/start_peer /usr/local/bin/start_peer
RUN chmod 0755 /usr/local/bin/start_peer

WORKDIR /peer

ADD peer /peer

COPY --from=ruby_builder /usr/local/bundle /usr/local/bundle

EXPOSE 3000

CMD ["start_peer"]