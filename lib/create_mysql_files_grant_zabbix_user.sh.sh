create_mysql_files_grant_zabbix_user_sh(){
    local file=$1
    cat >${file} <<EOF
#!/bin/bash
source /etc/profile

local_net=\`ip addr|awk -F'[/ ]+' '/inet/{print \$3}'|egrep "^192.168|^172.|^10\."|head -n 1|awk -F'.' -v OFS=.  '{print \$1,\$2,"%","%"}'\`
mysql_command="mysql -uroot -p${mysql_root_password} -h${mysql_host} -P${mysql_port}"
\${mysql_command} -e "create database ${zabbix_db_name};"
\${mysql_command} -e "grant all privileges on ${zabbix_db_name}.* to ${zabbix_db_user}@'${local_net}' identified by '${zabbix_db_password}';flush privileges;"
EOF
}
