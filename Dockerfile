FROM elixir:1.14

RUN apt-get update && apt-get install -y nodejs

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force 
    # && \
    #mix archive.install hex phx_new 1.6.16

# set build ENV 
ENV MIX_ENV="prod"

ENV DATABASE_URL="ecto://postgres:postgres@postgres/habits_db"

RUN mkdir /app

COPY . /app/

WORKDIR /app

RUN mix deps.get

RUN mix assets.deploy

RUN mix compile

RUN mix phx.digest

COPY entrypoint.sh entrypoint.sh