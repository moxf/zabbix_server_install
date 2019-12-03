# -------------------------------------------------------------------------------
# Revision:    1.0
# Date:        2019/11/25
# Author:      mox
# Email:       827897564@qq.com
# Description: Script to create the mysql ansible-playbook init file
# -------------------------------------------------------------------------------
# License:     GPL
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# you should have received a copy of the GNU General Public License
# along with this program (or with Nagios);
#
# Credits go to Ethan Galstad for coding Nagios
# If any changes are made to this script, please mail me a copy of the changes
# -------------------------------------------------------------------------------

create_mysql_files_init_mysql_sh(){
    local file=$1
    local end_eof=EOF
    cat > ${file} <<EOF
#!/bin/bash
source /etc/profile
set -o nounset
#set -o errexit

yum install -y libaio
yum -y remove mysql
rm -f /etc/my.cnf
log_file=/tmp/init_mysql.log

bindip=\`ip addr|awk -F'[/ ]+' '/inet/&&/brd/{print \$3}'|egrep "^192.168|^172.|^10\."|sed -n '1p'\`
local_net=\`ip addr|awk -F'[/ ]+' '/inet/{print \$3}'|egrep "^192.168|^172.|^10\."|head -n 1|awk -F'.' -v OFS=.  '{print \$1,\$2,"%","%"}'\`
svr_id="\`echo \${bindip}|awk -F. '{print \$NF}'\`${mysql_port:0-2}"
mysql_command="${mysql_app_dir}/bin/mysql -uroot -p${mysql_root_password} -h\${bindip} -P${mysql_port}"
mkdir -p ${mysql_app_dir} ${mysql_data_dir} ${mysql_data_dir}/../logs

cd ${remote_src_dir} && cp -rf ${mysql_package_src}/* ${mysql_app_dir}/
cd ${mysql_app_dir}/bin

#配置mysql
cat >${mysql_app_dir}/my.cnf <<EOF
[client]
port = ${mysql_port}
socket = ${mysql_data_dir}/mysql.sock
default_character_set = utf8mb4

[mysqld]
bind-address = \${bindip}
port = ${mysql_port}
socket = ${mysql_data_dir}/mysql.sock
basedir = ${mysql_app_dir}
datadir = ${mysql_data_dir}

#gtid
server_id= \${svr_id}
gtid_mode=on
enforce_gtid_consistency=on
master_info_repository=table
relay_log_info_repository=table

#innodb
innodb_temp_data_file_path = ibtmp1:12M:autoextend:max:5G
innodb_buffer_pool_size = ${innodb_buffer_pool_size}
innodb_buffer_pool_instances=8
innodb_file_per_table=on
innodb_write_io_threads = 4
innodb_read_io_threads = 4
innodb_thread_concurrency = 64

#innodb log
innodb_log_file_size = 1024M
innodb_log_buffer_size = 64M
innodb_log_files_in_group=3

#innodb zero data lost variables
innodb_flush_log_at_trx_commit = 1
innodb_doublewrite=on
sync_binlog=1
innodb_support_xa=on

#tx commit action is heavy action
autocommit=on
transaction_isolation=READ-COMMITTED
lower_case_table_names=1

#character
init_connect = 'SET NAMES utf8mb4'
character_set_server=utf8mb4

#connect
max_connections = 1600
max_connect_errors=9999999
sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'

#querycache
query_cache_size = 0M
query_cache_type=0

#mysql log
binlog_format=row
#log-bin-trust-function-creators=1
log_bin = ${mysql_data_dir}/../logs/mysql_bin.log

binlog-checksum=CRC32
log_timestamps=system
log_output='file'
general_log=off
general_log_file=${mysql_data_dir}/../logs/general.log
relay_log = ${mysql_data_dir}/../mysql-relay-bin.log
relay_log_purge =on
max_binlog_size = 1024M
log_slave_updates=on
expire_logs_days = 7
slow_query_log_file = ${mysql_data_dir}/../logs/mysql_slow_query.log
slow_query_log=on
long_query_time=1
#skip_name_resolve=on

#slave no semi ,group commit set
#skip_slave_start
slave-skip-errors=off
#replicate_ignore_db=mysql
#replicate_wild_ignore_table=mysql.%
loose-rpl_semi_sync_master_enabled=0

slave_parallel_workers=8
slave_parallel_type=LOGICAL_CLOCK
binlog_group_commit_sync_delay=0
binlog_group_commit_sync_no_delay_count=0
relay_log_recovery=1
relay-log-info-repository=TABLE
master-info-repository=TABLE

#resource limit
max_allowed_packet = 128M
innodb_lock_wait_timeout = 50
open_files_limit = 65535
interactive_timeout=86400
wait_timeout=86400
max_prepared_stmt_count=150000

#use audit
binlog_rows_query_log_events=on
explicit_defaults_for_timestamp=true

skip-grant-tables
${end_eof}


cd ${mysql_app_dir}/bin
./mysqld --no-defaults --basedir=${mysql_app_dir}  --datadir=${mysql_data_dir} --initialize-insecure --user=ops 2>>\${log_file}
chown -R ${mysql_run_user}:${mysql_run_user} \`dirname ${mysql_data_dir}\`
sed -i "1,/^basedir=.*/s@^basedir=.*@basedir=${mysql_app_dir}@" ${mysql_app_dir}/support-files/mysql.server
sed -i "1,/^datadir.*/s@^datadir=.*@datadir=${mysql_data_dir}@" ${mysql_app_dir}/support-files/mysql.server
#修改运行用户
sed -i s@^user=.*@user=${mysql_run_user}@ ${mysql_app_dir}/bin/mysqld_safe
#设置localhost解析内网ip
sed -i "s@127.0.0.1@\${bindip}@g" /etc/hosts

#启动mysql
${mysql_app_dir}/support-files/mysql.server start

#重置root用户过期标识,避免使用时需要交互修改密码
\${mysql_command} -e "use mysql; update user set password_expired='N' where User='root';"

#设置root密码
\${mysql_command} -e "update mysql.user set authentication_string=password('${mysql_root_password}') where user='root';flush privileges;" 2>>\${log_file}

#删除跳过授权配置
sed -i 's/skip-grant-tables//' ${mysql_app_dir}/my.cnf

#重启mysql
${mysql_app_dir}/support-files/mysql.server restart

mkdir -p /data/save
echo ${mysql_root_password} >/data/save/mysql_root

cat >/etc/profile.d/mysql.sh <<EOF
export PATH=\\\$PATH:${mysql_app_dir}/bin/
${end_eof}
source /etc/profile.d/mysql.sh

EOF
}
