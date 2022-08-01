FROM ruby:latest

WORKDIR /app

COPY config.ru /app
COPY Gemfile /app

RUN bundle install --quiet

EXPOSE 9001

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "9001"]
