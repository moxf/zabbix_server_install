create_nginx_templates_nginx_conf(){
    local file=$1
    cat >${file} <<EOF
user ${nginx_run_user};
pid ${nginx_app_dir}/nginx.pid;
worker_processes 4;
worker_rlimit_nofile 65535;

events {
    use epoll;
    worker_connections  65535;
    multi_accept on;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"'
          '\$connection \$upstream_addr '
          'upstream_response_time \$upstream_response_time request_time \$request_time ';

    error_log  ${nginx_log_dir}/error.log;

    sendfile   on;
    tcp_nopush on;
    tcp_nodelay on;

    keepalive_timeout  65;
    keepalive_requests 100000;
    #解决css/js无法加载问题
    proxy_buffer_size 128k;
    proxy_buffers   32 128k;
    proxy_busy_buffers_size 128k;

    client_max_body_size 2000m;
    large_client_header_buffers 4 32k;
    client_header_timeout 60;
    client_body_timeout 10;
    send_timeout 10;
    client_header_buffer_size 128k;
    open_file_cache max=65535 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 1;
    open_file_cache_errors on;

    proxy_ignore_client_abort on;

    gzip on;
    gzip_min_length  2048;
    gzip_buffers     4 16k;
    gzip_http_version 1.1;
    gzip_types  text/plain  text/css application/xml application/x-javascript image/jpeg image/jpg image/gif image/png;

    server_tokens off;

    include vhost/*.conf;
}
EOF
}
