from ruby:2.3.1

env DEBIAN_FRONTEND noninteractive

run sed -i '/deb-src/d' /etc/apt/sources.list && \
  apt-get update

run apt-get install -y build-essential postgresql-client nodejs
run apt-get install -y redis-server
run gem install bundler

workdir /tmp
copy Gemfile Gemfile
copy Gemfile.lock Gemfile.lock
copy .env.sample .env

run bundle install
run npm install

run mkdir /app
workdir /app

cmd ["bundle", "exec", "foreman", "start", "-f" , "Procfile.development"]
