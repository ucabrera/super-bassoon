# Dockerfile

FROM ruby:3.0.2

WORKDIR /app

COPY Gemfile .

RUN bundle install

EXPOSE 4567

COPY . /app

CMD ["bundle", "exec", "thin", "start", "-p", "4567"]
