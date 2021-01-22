FROM ruby:2.7-slim

RUN apt-get -qq update && \
    apt-get -qq -y install build-essential --fix-missing --no-install-recommends

ENV APP_HOME /app

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile Gemfile.lock ./

RUN bundle config set without 'development'
RUN bundle install
RUN bundle binstubs --all

RUN ln -sf /dev/stderr /app/tesla_puck.log

ADD . .
EXPOSE 9292
