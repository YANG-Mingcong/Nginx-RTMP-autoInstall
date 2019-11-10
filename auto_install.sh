sudo yum -y groupinstall 'Development Tools'
sudo yum -y install epel-release
sudo yum upgrade -y
sudo yum install -y  wget git unzip perl perl-devel perl-ExtUtils-Embed libxslt libxslt-devel libxml2 libxml2-devel gd gd-devel pcre-devel GeoIP GeoIP-devel
cd /usr/local/src


sudo wget http://nginx.org/download/nginx-1.17.5.tar.gz
sudo wget https://ftp.pcre.org/pub/pcre/pcre-8.42.zip
sudo wget https://www.zlib.net/zlib-1.2.11.tar.gz
sudo wget https://www.openssl.org/source/openssl-1.1.0h.tar.gz
sudo git clone https://github.com/YANG-Mingcong/nginx-rtmp-module.git

sudo tar -xzvf nginx-1.17.5.tar.gz
sudo unzip pcre-8.42.zip
sudo tar -xzvf zlib-1.2.11.tar.gz
sudo tar -xzvf openssl-1.1.0h.tar.gz
sudo rm -f *.tar.gz *.zip

cd /usr/local/src/nginx-1.17.5

sudo ./configure --prefix=/etc/nginx \
            --sbin-path=/usr/sbin/nginx \
            --modules-path=/usr/lib64/nginx/modules \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --pid-path=/var/run/nginx.pid \
            --lock-path=/var/run/nginx.lock \
            --user=nginx \
            --group=nginx \
            --build=CentOS \
            --builddir=nginx-1.17.5 \
            --with-select_module \
            --with-poll_module \
            --with-threads \
            --with-file-aio \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-http_realip_module \
            --with-http_addition_module \
            --with-http_xslt_module=dynamic \
            --with-http_image_filter_module=dynamic \
            --with-http_geoip_module=dynamic \
            --with-http_sub_module \
            --with-http_dav_module \
            --with-http_flv_module \
            --with-http_mp4_module \
            --with-http_gunzip_module \
            --with-http_gzip_static_module \
            --with-http_auth_request_module \
            --with-http_random_index_module \
            --with-http_secure_link_module \
            --with-http_degradation_module \
            --with-http_slice_module \
            --with-http_stub_status_module \
            --http-log-path=/var/log/nginx/access.log \
            --http-client-body-temp-path=/var/cache/nginx/client_temp \
            --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
            --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
            --with-mail=dynamic \
            --with-mail_ssl_module \
            --with-stream=dynamic \
            --with-stream_ssl_module \
            --with-stream_realip_module \
            --with-stream_geoip_module=dynamic \
            --with-stream_ssl_preread_module \
            --with-compat \
            --with-pcre=../pcre-8.42 \
            --with-pcre-jit \
            --with-zlib=../zlib-1.2.11 \
            --with-openssl=../openssl-1.1.0h \
            --with-openssl-opt=no-nextprotoneg \
            --add-module=../nginx-rtmp-module \
            --with-debug

sudo make

sudo make install

sudo ln -s /usr/lib64/nginx/modules /etc/nginx/modules

sudo useradd -r -d /var/cache/nginx/ -s /sbin/nologin -U nginx
sudo mkdir -p /var/cache/nginx/
sudo chown -R nginx:nginx /var/cache/nginx/

sudo nginx -t
sudo nginx -V

# sudo cd /lib/systemd/system/nginx.service

sudo echo -e "[Unit]\nDescription=nginx - high performance web server\nDocumentation=https://nginx.org/en/docs/\nAfter=network-online.target remote-fs.target nss-lookup.target\nWants=network-online.target\n\n[Service]\nType=forking\nPIDFile=/var/run/nginx.pid\nExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx.conf\nExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf\nExecReload=/bin/kill -s HUP $MAINPID\nExecStop=/bin/kill -s TERM $MAINPID\n\n[Install]\nWantedBy=multi-user.target" >/lib/systemd/system/nginx.service

sudo systemctl daemon-reload
sudo systemctl start nginx
sudo systemctl enable nginx


# auto configuration
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.asli
cd /usr/local/src/
sudo rm -rf /usr/local/src/nginx.conf
sudo wget https://raw.githubusercontent.com/YANG-Mingcong/Nginx-RTMP-autoInstall/master/nginx.conf

sudo cp /usr/local/src/nginx.conf /etc/nginx/nginx.conf
sudo chown nginx:nginx /etc/nginx/nginx.conf

sudo mkdir -p /mnt/hls
sudo chown -R nginx:nginx /mnt/hls
sudo systemctl restart nginx

