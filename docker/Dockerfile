FROM ruby:latest

ENV COMPOSE_VERSION 1.7.1
ENV MACHINE_VERSION 0.7.0

RUN apt-get update -q \
	&& apt-get install -y -q --no-install-recommends curl ca-certificates \
	&& curl -o /usr/local/bin/docker-compose -L \
		"https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-Linux-x86_64" \
	&& chmod +x /usr/local/bin/docker-compose

RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby --with-gems="bundle"

COPY ./Gemfile Gemfile

RUN /bin/bash -c "source /usr/local/rvm/scripts/rvm && rvm @global do bundle install"

CMD ["source /usr/local/rvm/scripts/rvm"]
