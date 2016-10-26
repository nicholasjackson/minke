#!/usr/bin/env bash
INSTALL="echo \"#Copying cache\" && gem install bundler && bundle install"
COMMAND="bundle exec minke $@"

if [[ $1 != \generate* ]]; then
  if [ -d "./vendor" ]; then
    eval $COMMAND 
  else  
    eval "$INSTALL && $COMMAND"
  fi
fi

if [[ $1 = \generate* ]]; then
  eval $COMMAND
fi
