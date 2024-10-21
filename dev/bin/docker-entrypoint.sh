#!/bin/bash -e

# If running the rails server then create or migrate existing database
if [ "$RAILS_ENV" = "development" ]; then
  echo "The dev/bin/docker-entrypoint file has been loaded."
  ./bin/rails db:prepare
fi

exec "${@}"
