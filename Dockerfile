FROM ruby:2.6.3
RUN apt-get update -qq && \
    apt-get install -y mysql-client && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash && \
    apt-get install nodejs

RUN mkdir /railsapp
WORKDIR /railsapp
COPY Gemfile /railsapp/Gemfile
COPY Gemfile.lock /railsapp/Gemfile.lock
RUN bundle install
COPY . /railsapp

EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]