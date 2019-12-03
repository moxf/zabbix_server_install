#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    setup.sh
# Revision:    1.0
# Date:        2019/11/21
# Author:      mox
# Email:       827897564@qq.com
# Description: Script to install the zabbix_server
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

source /etc/profile
shell_dir=`cd $(dirname $0);pwd`
source ${shell_dir}/config.ini
host_file=${shell_dir}/hosts
log_dir=${shell_dir}/log
mkdir -p ${log_dir}
log_file=${log_dir}/setup.log
declare -A full_host_set
start_time=`date +%s`


load_lib(){
    lib_dir=${shell_dir}/lib
    lib_main=${lib_dir}/main.sh
    if [ -f ${lib_main} ];then
        rm -f ${lib_main}
    fi
    for lib in `ls ${lib_dir}|grep ".sh$"`;do
        echo "source ${lib_dir}/${lib}" >>${lib_main}
    done
    source ${lib_main}
}


log(){
    DATE_OUT="date +%F-%H:%M:%S"
    if [ $# -gt 1  ];then
        echo -e "\\033[32m [`$DATE_OUT`]: $1 \\033[0m"
        echo "[`$DATE_OUT`]: $1" >>${log_file}
    else
        echo "[`$DATE_OUT`]: $1" >>${log_file}
    fi
}


err_log(){
    DATE_OUT="date +%F-%H:%M:%S"
    if [ $# -gt 1  ];then
        echo -e "\\033[31m [`$DATE_OUT`]: erro! $1 \\033[0m"
        echo "[`$DATE_OUT`]: $1" >>${log_file}
    else
        echo "[`$DATE_OUT`]: $1" >>${log_file}
    fi
    exit 7
}


check_package(){
    package=$1
    if [ ! -f ${package} ];then
        err_log "${package} not found" yes
    fi
}


write_hosts(){

    #写入nginx==>hosts
    echo '[nginx]' >${host_file}
    echo ${nginx_host} >>${host_file}

    echo "" >>${host_file}
    echo '[php]' >>${host_file}
    echo ${php_host} >>${host_file}

    echo "" >>${host_file}
    echo '[mysql]' >>${host_file}
    echo ${mysql_host} >>${host_file}

    echo "" >>${host_file}
    echo '[zabbix]' >>${host_file}
    echo ${zabbix_host} >>${host_file}
}


load_var(){

    package_src=${shell_dir}/src
    nginx_package=${package_src}/${nginx_package_name}
    nginx_upstream=${package_src}/${nginx_upstream_check_package_name}
    pcre_package=${package_src}/${pcre_package_name}
    nginx_echo=${package_src}/${nginx_echo_mode_package_name}
    nginx_dir=`echo ${nginx_package_name}|sed "s@.tar.gz@@"`
    pcre_dir=`echo ${pcre_package_name}|sed "s@.tar.gz@@"`
    upstream_check_dir=`echo ${nginx_upstream_check_package_name}|sed "s@.zip@@"`
    
    nginx_cert_dir=${nginx_app_dir}/cert
    nginx_config_dir=${nginx_app_dir}/conf
    nginx_vhost_conf_dir=${nginx_config_dir}/vhost
    nginx_remote_src=${remote_src_dir}/${nginx_dir}
    pcre_remote_src=${remote_src_dir}/${pcre_dir}
    upstream_check_remote_src=${remote_src_dir}/${upstream_check_dir}

    php_package=${package_src}/${php_package_name}
    libzip_package=${package_src}/${libzip_package_name}

    mysql_package=${package_src}/${mysql_package_name}
    mysql_package_src=`echo ${mysql_package_name}|sed 's@.tar.gz@@'`

    zabbix_package=${package_src}/${zabbix_package_name}
    font_file=${package_src}/simkai.ttf
}


init_ansible_roles(){

    declare -A handler_file_set
    declare -A nginx_file_set
    declare -A php_file_set
    declare -A mysql_file_set
    declare -A zabbix_file_set

    local mode_name=$1
    local roles_dir=${shell_dir}/roles/${mode_name}
    case ${mode_name} in
        nginx)
            nginx_init_script_name=init_nginx.sh 
            nginx_main_config=nginx.conf
            nginx_unit_file=nginx.service
            zabbix_vhost_config=zabbix.conf
            nginx_file_set=([files]="${nginx_init_script_name}" [templates]="${nginx_main_config},${zabbix_vhost_config},${nginx_unit_file}" [tasks]='main.yml')
            for key in ${!nginx_file_set[*]};do
                handler_file_set[${key}]=${nginx_file_set[${key}]}
            done
            ;;
        php)
            php_init_script_name=init_php.sh
            php_support_zabbix_script=php_support_zabbix.sh
            php_file_set=([files]="${php_init_script_name},${php_support_zabbix_script}" [handlers]='main.yml' [tasks]='main.yml')
            for key in ${!php_file_set[*]};do
                handler_file_set[${key}]=${php_file_set[${key}]}
            done
            ;;
        mysql)
            mysql_init_script_name=init_mysql.sh
            mysql_grant_zabbix=grant_zabbix_user.sh
            mysql_file_set=([files]="${mysql_init_script_name},${mysql_grant_zabbix}" [tasks]='main.yml')
            for key in ${!mysql_file_set[*]};do
                handler_file_set[${key}]=${mysql_file_set[${key}]}
            done
            ;;
        zabbix)
            zabbix_init_script_name=init_zabbix.sh
            zabbix_config_name=zabbix_server.conf
            zabbix_unit_file=zabbix-server.service
            zabbix_file_set=([files]="${zabbix_init_script_name}" [templates]="${zabbix_config_name},${zabbix_unit_file}" [tasks]='main.yml')
            for key in ${!zabbix_file_set[*]};do
                handler_file_set[${key}]=${zabbix_file_set[${key}]}
            done
            ;;
    esac    

    for dir_name in ${!handler_file_set[*]};do
        local file_dir=${roles_dir}/${dir_name}
        mkdir -p ${file_dir}
        for file_name in `echo ${handler_file_set[${dir_name}]}|sed "s@,@ @g"`;do
            local file_path=${file_dir}/${file_name}
            local postfix=`echo ${file_name}|awk -F. '{print $NF}'`
            local function_name=create_${mode_name}_${dir_name}_${file_name%.*}_${postfix}
            #echo function_name:${function_name}
            `$function_name ${file_path}`
        done
    done

}


main(){
    load_var
    load_lib
    write_hosts
    init_ansible_roles nginx
    init_ansible_roles php
    init_ansible_roles mysql
    init_ansible_roles zabbix
    
    echo "ansible-playbook  -i ${shell_dir}/../hosts  --user=${remote_user} ${shell_dir}/setup.yml"
    ansible-playbook  -i ${shell_dir}/hosts -l all --user=${remote_user} ${shell_dir}/setup.yml
}

main
end_time=`date +%s`
let use_time=end_time-start_time
echo use_time:${use_time}


