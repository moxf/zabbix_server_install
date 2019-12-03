# -------------------------------------------------------------------------------
# Revision:    1.0
# Date:        2019/11/30
# Author:      mox
# Email:       827897564@qq.com
# Description: Script to create the zabbix ansible-playbook tasks
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

create_zabbix_tasks_main_yml(){
    local file=$1
    cat >${file} <<EOF
-   name: check ${remote_src_dir}
    file:
        path: "${remote_src_dir}"
        state: directory
        mode: 0755
-   name: unarchive ${zabbix_package} to ${remote_src_dir}
    unarchive:
        src: "${zabbix_package}" 
        dest: "${remote_src_dir}"
-   name: init zabbix
    script: ${zabbix_init_script_name} 
    register: result
-   name: show init result
    debug:
        var: result
        verbosity: 0
-   name: copy ${zabbix_config_name} to ${zabbix_app_dir}/etc/ 
    template: 
        src: ${zabbix_config_name}
        dest: ${zabbix_app_dir}/etc/ 
-   name: copy ${zabbix_unit_file} to /etc/systemd/system/
    template:
        src: ${zabbix_unit_file}
        dest: /etc/systemd/system/${zabbix_unit_file}
-   name: start zabbix-server
    systemd:
        daemon_reload: true
        name: zabbix-server
        state: started
        enabled: true
-   name: copy ${font_file} to ${zabbix_web_root}
    copy:
        src: ${font_file}
        dest: ${zabbix_web_root}/assets/fonts/
-   name: restart php-fpm
    systemd:
        name: php-fpm
        state: restarted
EOF
}
