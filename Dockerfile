# Dockerfile

FROM ruby:3.1.2

WORKDIR /app

COPY Gemfile .

RUN bundle install

EXPOSE 3001

COPY . /app

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]