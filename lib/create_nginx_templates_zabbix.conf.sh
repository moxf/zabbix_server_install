create_nginx_templates_zabbix_conf(){
    local file=$1
    cat >${file} <<EOF
server {

    listen 80;
    server_name ${zabbix_domain};
    root ${zabbix_web_root};
    access_log ${nginx_log_dir}/zabbix.log  main;
    index index.php;

    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME   \$document_root\$fastcgi_script_name;
        include        fastcgi_params;
     }
}
EOF
}
