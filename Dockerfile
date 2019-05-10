FROM ruby:2.6.3
RUN apt-get update -qq && \
    apt-get install -y mysql-client && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash && \
    apt-get install nodejs && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt update && apt-get install yarn

RUN mkdir /railsapp
WORKDIR /railsapp
COPY Gemfile /railsapp/Gemfile
COPY Gemfile.lock /railsapp/Gemfile.lock
RUN bundle install
COPY . /railsapp

EXPOSE 3000