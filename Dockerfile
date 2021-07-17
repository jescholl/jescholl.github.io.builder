FROM ruby:2.4.3

COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install
COPY . .


