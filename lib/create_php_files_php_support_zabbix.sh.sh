create_php_files_php_support_zabbix_sh(){
    local file=$1
    cat > ${file} <<EOF
#!/bin/bash
source /etc/profile
php_config=${php_app_dir}/etc/php.ini

sed -i 's@post_max_size = .*@post_max_size = 16M@' \${php_config}
sed -i 's@max_execution_time = .*@max_execution_time = 300@' \${php_config}
sed -i 's@max_input_time = .*@max_input_time = 300@' \${php_config}
sed -i 's@;date.timezone.*@date.timezone = "Asia/Shanghai"@' \${php_config}

EOF

}
