create_nginx_files_init_nginx_sh(){
    local file=$1
    cat >${file} <<EOF
#!/bin/bash
source /etc/profile
mkdir -p ${nginx_cert_dir}
mkdir -p ${nginx_vhost_conf_dir}
mkdir -p ${zabbix_web_root}
mkdir -p ${nginx_log_dir}
cpu_num=\`cat /proc/cpuinfo |grep "processor"|wc -l\`

cd ${nginx_remote_src} 
patch -p1 < ${upstream_check_remote_src}/check_1.14.0+.patch
./configure --prefix=${nginx_app_dir} --with-http_ssl_module --with-http_stub_status_module --with-pcre=${pcre_remote_src} --add-module=${upstream_check_remote_src}
make -j \${cpu_num} && make install
EOF
}
