#!/bin/sh


# get private key and add too ssh client
echo $PRIVATE_KEY > private_key_file.txt
cat private_key_file.txt | base64 --decode > private_key
chmod 600 private_key
eval `ssh-agent -s`
ssh-agent $(ssh-add private_key);
#ssh to server and run commands
ssh $SSH_PATH <<EOF
    cd $DEPLOY_DIR

    git pull origin master

    #cd into container
    docker exec -t web bash

    # activate maintenance mode
    php artisan down

    composer install --no-interaction
	# --no-interaction	Do not ask any interactive question
	# --no-dev		Disables installation of require-dev packages.

    # Clear caches
    php artisan cache:clear
    php artisan config:clear
    php artisan route:clear
    php artisan view:clear

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

