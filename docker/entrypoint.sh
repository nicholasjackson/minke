#!/usr/bin/env bash

INSTALL="echo \"#Copying cache\" && cp -r /usr/local/backup/* /usr/local/bundle/ && gem install bundler && bundle install"
COMMAND="bundle exec minke $@"

if [ "$(ls -A ./vendor)" ]; then
  eval $COMMAND 
else  
  eval "$INSTALL && $COMMAND"
fi
