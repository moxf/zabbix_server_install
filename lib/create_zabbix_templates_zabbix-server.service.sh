create_zabbix_templates_zabbix-server_service(){
    local file=$1
    cat >${file} <<EOF
[Unit]
Description=Zabbix Server
After=syslog.target
After=network.target

[Service]
Environment="CONFFILE=${zabbix_app_dir}/etc/zabbix_server.conf"
EnvironmentFile=-/etc/sysconfig/zabbix-server
Type=forking
Restart=on-failure
PIDFile=${zabbix_app_dir}/zabbix_server.pid
KillMode=control-group
ExecStart=${zabbix_app_dir}/sbin/zabbix_server -c \$CONFFILE
ExecStop=/bin/kill -SIGTERM \$MAINPID
RestartSec=10s
TimeoutSec=0

[Install]
WantedBy=multi-user.target
EOF
}
