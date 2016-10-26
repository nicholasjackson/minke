#!/usr/bin/env bash
bundle_install=true

if [[ -e "Gemfile.sha" ]]; then
  sha=`cat Gemfile.sha`
  current_sha=`sha1sum Gemfile`

  if [[ "$sha" == "$current_sha" ]]; then
    bundle_install=false
  fi
fi

if $bundle_install; then
  bundle install
  sha1sum Gemfile > Gemfile.sha
fi

COMMAND="bundle exec minke $@"
eval $COMMAND
