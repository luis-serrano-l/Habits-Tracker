FROM elixir:1.14

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV 
ENV MIX_ENV="prod"

RUN mkdir /app

COPY . /app/

WORKDIR /app

RUN mix deps.get

RUN mix compile

RUN mix phx.digest

# COPY ./docker-entrypoint.sh /

# ENTRYPOINT [ "./docker-entrypoint.sh" ]

CMD [ "mix", "phx.server" ]