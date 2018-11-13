#!/bin/sh


# get private key and add too ssh client
echo $PRIVATE_KEY > private_key_file.txt
cat private_key_file.txt | base64 --decode > private_key
chmod 600 private_key
eval `ssh-agent -s`
ssh-agent $(ssh-add private_key);
#ssh to server and run commands
ssh root@social.timbu.com <<EOF
    git pull origin master
    cd src

    # activate maintenance mode
    php artisan down

    composer install --no-interaction --no-dev
	# --no-interaction	Do not ask any interactive question
	# --no-dev		Disables installation of require-dev packages.

    # Clear caches
    php artisan cache:clear


    # Clear and cache routes
    php artisan route:clear
    php artisan route:cache

    # Clear and cache config
    php artisan config:clear
    php artisan config:cache

    # Install node modules
    npm install

    # Build assets using Laravel Mix
    npm run production

    # update database
    php artisan migrate --force
	# --force		Required to run when in production.

    # seed database
    php artisan db:seed --force

    # stop maintenance mode
    php artisan up
EOF

# update PHP dependencies

