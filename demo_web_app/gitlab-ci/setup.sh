#!/bin/bash -xe

apt-get update
apt-get install -y nodejs

cp gitlab-ci/database.yml config/database.yml

bundle check --path=${BUNDLE_CACHE} || bundle install --path=${BUNDLE_CACHE} --jobs=2 --retry=3

bundle exec rake db:create
bundle exec rake db:migrate:reset

