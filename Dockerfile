# Dockerfile

FROM ruby:3.1.2

WORKDIR /app

COPY Gemfile .

RUN bundle install


EXPOSE 4567

COPY . /app

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]