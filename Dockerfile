FROM ruby:2.3.8-stretch

RUN mkdir /app

COPY script/build/debian/prebuild.sh app/script/build/debian/prebuild.sh
RUN app/script/build/debian/prebuild.sh
COPY script/build/debian/node.sh app/script/build/debian/node.sh
RUN app/script/build/debian/node.sh

RUN apt-get update && apt-get install libjemalloc1 && rm -rf /var/lib/apt/lists/*
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.1

COPY gems /app/gems/

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

COPY package.json /app
RUN npm install

COPY . /app

ENV NODE_ICU_DATA=/usr/lib/node_modules/icu4c-data

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

CMD foreman start
