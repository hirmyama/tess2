#!/bin/bash -ex

# Apache, PHP, MySQLクライアントをインストール
sudo yum update -y
sudo amazon-linux-extras install -y php7.3=7.3.11
sudo yum install -y mysql httpd php-mbstring php-xml gd php-gd
sudo chown apache:apache /var/www/html

# WordPressをインストール
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/bin/wp
sudo mkdir -p /usr/share/httpd/.wp-cli/cache/
sudo chown apache:apache /usr/share/httpd/.wp-cli/cache/
sudo -u apache wp core download --version=5.3 --locale=ja --path=/var/www/html

# タイトルに日本語が使えるようにする
cat <<EOF |sudo tee /etc/httpd/conf.d/wp.conf
<Directory /var/www/html>
  AllowOverride All
</Directory>
EOF

# adminerを導入する
sudo curl -o /var/www/html/adminer.php -L https://www.adminer.org/latest-mysql.php
sudo chown apache:apache /var/www/html/adminer.php

# Apacheを起動
sudo systemctl enable --now httpd.service

# 動作確認
curl -L localhost;
