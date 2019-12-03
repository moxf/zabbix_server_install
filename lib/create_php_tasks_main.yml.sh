# -------------------------------------------------------------------------------
# Revision:    1.0
# Date:        2019/11/21
# Author:      mox
# Email:       827897564@qq.com
# Description: Script to create the php ansible-playbook tasks
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
create_php_tasks_main_yml(){
    local file=$1
    cat >${file} <<EOF
-   name: check ${remote_src_dir}
    file: 
        path: "${remote_src_dir}"
        state: directory
        mode: 0755
-   name: unarchive package to remote_src_dir:${remote_src_dir}
    unarchive:
        src: "{{ item }}"
        dest: "${remote_src_dir}"
    with_items:
        -   "${php_package}" 
        -   "${libzip_package}"
-   name: init php
    script: "${php_init_script_name}"
-   name: config php support zabbix
    script: "${php_support_zabbix_script}"
EOF
}
