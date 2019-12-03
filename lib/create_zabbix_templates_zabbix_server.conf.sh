create_zabbix_templates_zabbix_server_conf(){
    local file=$1
    cat >${file} <<EOF
DBName=${zabbix_db_name}
DBUser=${zabbix_db_user}
DBPassword=${zabbix_db_password}
DBHost=${mysql_host}
DBPort=${mysql_port}
Timeout=15
AlertScriptsPath=${zabbix_app_dir}/bin
LogSlowQueries=3000
LogFile=${zabbix_log_dir}/zabbix_server.log
User=${zabbix_run_user}
PidFile=${zabbix_app_dir}/zabbix_server.pid
EOF
}
