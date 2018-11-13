#!/bin/sh
# activate maintenance mode
php artisan down

# update source code
#git pull
cat $PRIVATE_KEY | base64 --decode > ~/.ssh/private_key

chmod 600 ~/.ssh/private_key
eval `ssh-agent -s`
ssh-agent $(ssh-add ~/.ssh/private_key; git pull origin master)
ssh root@social.timbu.com -v
ls

# update PHP dependencies
export COMPOSER_HOME='/tmp/composer'

composer install --no-interaction
	# --no-interaction	Do not ask any interactive question
	# --no-dev		Disables installation of require-dev packages.
	# --prefer-dist		Forces installation from package dist even for dev versions.

# update database
php artisan migrate --force
	# --force		Required to run when in production.
# seed database
php artisan db:seed --force

# stop maintenance mode
php artisan up