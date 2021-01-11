FROM ruby:2.7-slim

RUN apt-get -qq update && \
    apt-get -qq -y install build-essential --fix-missing --no-install-recommends

ENV APP_HOME /app

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

COPY Gemfile Gemfile.lock ./

RUN bundle install
RUN bundle binstubs --all

COPY . .
EXPOSE 9292
