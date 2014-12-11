#!/bin/bash
clear

echo "Upgrading...."
git stash
git pull https://SteffanPerry@github.com/SteffanPerry/blizzard.git master
chown apache.root ./ -R
chmod 755 ./ -R
rm -rf Gemfile.lock
rake tmp:cache:clear
rake tmp:sockets:clear
rake tmp:pids:clear
rake tmp:sessions:clear

touch tmp/restart.txt

echo "Completed"