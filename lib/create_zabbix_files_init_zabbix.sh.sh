create_zabbix_files_init_zabbix_sh(){
    local file=$1
    end_eof=EOF
    cat >${file} <<EOF
#!/bin/bash
source /etc/profile
cpu_num=\`cat /proc/cpuinfo |grep "processor"|wc -l\`
mysql_command="mysql -u${zabbix_db_user} -p${zabbix_db_password} -h${mysql_host} -P${mysql_port}" 

check_command(){
    err_code=\$?
    if [ \$err_code -ne 0 ];then
        echo "ERRO! \${1}失败"
        exit 7
    else
        echo "\${1} OK"
    fi
}

yum -y install libxml2 libxml2-devel libevent-devel libevent 

mkdir -p ${zabbix_log_dir}
cd ${remote_src_dir}/zabbix-*
./configure --prefix=${zabbix_app_dir} --enable-server --enable-agent --with-mysql --with-net-snmp --with-libcurl --with-libxml2 
make -j \${cpu_num} && make install

chown -R ${zabbix_run_user}:${zabbix_run_user} ${zabbix_app_dir}

cd ${remote_src_dir}/zabbix-*
/bin/cp -rf frontends/php/*  ${zabbix_web_root}/
\${mysql_command} ${zabbix_db_name} < database/mysql/schema.sql
check_command "import database/mysql/schema.sql"
\${mysql_command} ${zabbix_db_name} < database/mysql/images.sql
check_command "import database/mysql/images.sql"
\${mysql_command} ${zabbix_db_name} < database/mysql/data.sql
check_command "import database/mysql/data.sql"

#解决zabbix图形中文乱码
sed -i "s@realpath.*@realpath('fonts'));@" ${zabbix_web_root}/include/defines.inc.php
sed -i 's@DejaVuSans@simkai@g' ${zabbix_web_root}/include/defines.inc.php

cat >${zabbix_web_root}/conf/zabbix.conf.php <<EOF
<?php
// Zabbix GUI configuration file.
global \\\$DB;

\\\$DB['TYPE']     = 'MYSQL';
\\\$DB['SERVER']   = '${mysql_host}';
\\\$DB['PORT']     = '${mysql_port}';
\\\$DB['DATABASE'] = '${zabbix_db_name}';
\\\$DB['USER']     = '${zabbix_db_user}';
\\\$DB['PASSWORD'] = '${zabbix_db_password}';

// Schema name. Used for IBM DB2 and PostgreSQL.
\\\$DB['SCHEMA'] = '';

\\\$ZBX_SERVER      = 'localhost';
\\\$ZBX_SERVER_PORT = '10051';
\\\$ZBX_SERVER_NAME = '';

\\\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;

${end_eof}

EOF
}
