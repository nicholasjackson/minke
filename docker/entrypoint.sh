#!/usr/bin/env bash

INSTALL="echo \"#Copying cache\" && cp -r /usr/local/bundle/backup/* /usr/local/bundle/gems"
COMMAND="bundle exec minke $@"

[ "$(ls -A ./vendor/gems)" ] && eval "$INSTALL && $COMMAND" || eval $COMMAND