create_php_templates_php-fpm_service(){
    local file=$1
    cat >${file} <<EOF
[Unit]
Description=The PHP FastCGI Process Manager
After=syslog.target network.target

[Service]
Type=simple
PIDFile=${php_app_dir}/var/run/php-fpm.pid
ExecStart=${php_app_dir}/sbin/php-fpm --nodaemonize --fpm-config ${php_app_dir}/etc/php-fpm.conf
ExecReload=/bin/kill -USR2 \$MAINPID

[Install]
WantedBy=multi-user.target
EOF
}
