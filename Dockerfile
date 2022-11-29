# Dockerfile

FROM ruby:3.1.2

WORKDIR /app

COPY Gemfile .

RUN bundle install

EXPOSE 4568

COPY . /app

CMD ["bundle", "exec", "thin", "start", "-p", "4568"]