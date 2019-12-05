create_php_files_init_php_sh(){
    local file=$1
    end_eof=EOF
    cat >${file} <<EOF
#!/bin/bash
source /etc/profile
set -o nounset
set -o errexit
cpu_num=\`cat /proc/cpuinfo |grep "processor"|wc -l\`

mkdir -p ${php_log_dir}

yum -y install wget vim pcre pcre-devel openssl openssl-devel libicu-devel gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel glibc glibc-devel glib2 glib2-devel ncurses ncurses-devel curl curl-devel krb5-devel libidn libidn-devel  jemalloc-devel cmake automake libevent libevent-devel gd gd-devel libtool* libmcrypt libmcrypt-devel mcrypt mhash libxslt libxslt-devel readline readline-devel gmp gmp-devel libcurl libcurl-devel openjpeg-devel libzip libzip-devel

yum remove -y libzip
cd ${remote_src_dir}/libzip-*
./configure
make -j ${cpu_num} && make install
cp -f /usr/local/lib/libzip/include/zipconf.h /usr/local/include/zipconf.h


if ! (grep '/usr/lib' /etc/ld.so.conf);then
    cat >> /etc/ld.so.conf <<EOF
/usr/local/lib
/usr/lib
/usr/lib64
${end_eof}
fi
ldconfig -v  

cd ${remote_src_dir}/php-*
./configure --prefix=/opt/php \
--with-config-file-path=/opt/php/etc \
--enable-fpm \
--with-fpm-user=ops \
--with-fpm-group=ops \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-iconv-dir \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--enable-xml \
--disable-rpath \
--enable-magic-quotes \
--enable-safe-mode \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--with-curlwrappers \
--enable-mbregex \
--enable-mbstring  \
--enable-ftp \
--with-gd \
--enable-gd-native-ttf \
--with-openssl \
--with-mhash \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-zip \
--enable-soap \
--without-pear \
--with-gettext \
--disable-fileinfo \
--enable-maintainer-zts

make -j \${cpu_num} && make install


#配置php
mkdir -p ${php_app_dir}/etc/php-fpm.d
cat >${php_app_dir}/etc/php-fpm.d/www.conf <<EOF
[www]
listen = 127.0.0.1:9000
listen.mode = 0666

user = ${php_run_user}
group = ${php_run_user}

pm = dynamic
pm.max_children = 128
pm.start_servers = 20
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 10000

rlimit_files = 1024

slowlog = ${php_log_dir}/\\\$pool.log.slow
php_admin_value[error_log] = ${php_log_dir}/php-error.log
php_admin_flag[log_errors] = on
${end_eof}

cp ${remote_src_dir}/php-*/php.ini-production ${php_app_dir}/etc/php.ini
cp ${php_app_dir}/etc/php-fpm.conf.default ${php_app_dir}/etc/php-fpm.conf

chown -R ${php_run_user}:${php_run_user} ${php_log_dir} 
chown -R ${php_run_user}:${php_run_user} ${php_app_dir} 

systemctl daemon-reload
systemctl start php-fpm
systemctl enable php-fpm

EOF
}
