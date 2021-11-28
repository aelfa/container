#!/usr/bin/with-contenv sh

echo "Fixing perms..."
mkdir -p /data/rtorrent \
  /data/rutorrent \
  /etc/nginx/conf.d \
  /etc/rtorrent \
  /var/cache/nginx \
  /var/lib/nginx \
  /var/run/nginx \
  /var/run/php-fpm \
  /var/run/rtorrent

chown rtorrent. \
  /data \
  /data/rtorrent \
  /data/rutorrent

chown -R rtorrent. \
  /etc/rtorrent \
  /tpls \
  /var/cache/nginx \
  /var/lib/nginx \
  /var/log/php7 \
  /var/run/nginx \
  /var/run/php-fpm \
  /var/run/rtorrent
