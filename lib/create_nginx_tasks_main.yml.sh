# -------------------------------------------------------------------------------
# Revision:    1.0
# Date:        2019/11/25
# Author:      mox
# Email:       827897564@qq.com
# Description: Script to install the nginx
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

create_nginx_tasks_main_yml(){
    local k8s_tasks_file=$1
cat >${k8s_tasks_file} <<EOF
-   name: check ${remote_src_dir}
    file:
        path: "${remote_src_dir}"
        state: directory
        mode: 0755
-   name: unarchive source to ${remote_src_dir}
    unarchive:
        src: "{{ item }}"
        dest: "${remote_src_dir}"
    with_items:
        -   "${nginx_package}"
        -   "${nginx_upstream}"
        -   "${pcre_package}"
-   name: init nginx
    script: ${nginx_init_script_name}
    register: result
-   name: show init nginx result
    debug: 
        var: result
        verbosity: 0
-   name: copy nginx_main_config ${nginx_main_config} to ${nginx_config_dir}
    template:
        src:  "${nginx_main_config}"
        dest: "${nginx_config_dir}/${nginx_main_config}"
-   name: copy zabbix_vhost_config 
    template:
        src: "${zabbix_vhost_config}"
        dest: "${nginx_vhost_conf_dir}/${zabbix_vhost_config}"
-   name: copy nginx unit file to remote /etc/systemd/system/${nginx_unit_file}
    template:
        src: "${nginx_unit_file}"
        dest: "/etc/systemd/system/${nginx_unit_file}"
-   name: start nginx
    systemd:
        daemon_reload: true
        name: nginx
        state: started
        enabled: true
EOF
}
