# -------------------------------------------------------------------------------
# Revision:    1.0
# Date:        2019/11/29
# Author:      mox
# Email:       827897564@qq.com
# Description: Script to create nginx system unit file 
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


create_nginx_templates_nginx_service(){
    local file=$1
    cat >${file} <<EOF
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=${nginx_app_dir}/nginx.pid
# Nginx will fail to start if /run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running \`nginx -t\` from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f ${nginx_app_dir}/nginx.pid
ExecStartPre=${nginx_app_dir}/sbin/nginx -t
ExecStart=${nginx_app_dir}/sbin/nginx
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
}
