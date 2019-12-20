FROM centos:7

ENV NGINX_VERSION=1.16.1
ENV HTTP_FLV_MODULE_VERSION=1.2.7

RUN yum update -y
RUN yum install curl wget gcc make openssl-devel libxslt-devel pcre-devel zlib-devel -y

RUN mkdir -p /tempDir && cd /tempDir \
    && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && wget https://github.com/winshining/nginx-http-flv-module/archive/v${HTTP_FLV_MODULE_VERSION}.tar.gz \
    && tar -zxvf nginx-${NGINX_VERSION}.tar.gz \
    && tar -zxvf v${HTTP_FLV_MODULE_VERSION}.tar.gz \
    && cd nginx-${NGINX_VERSION} \
    && ./configure \
        --prefix=/usr/share/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib64/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --http-client-body-temp-path=/var/lib/nginx/tmp/client_body \
        --http-proxy-temp-path=/var/lib/nginx/tmp/proxy \
        --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi \
        --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi \
        --http-scgi-temp-path=/var/lib/nginx/tmp/scgi \
        --pid-path=/run/nginx.pid \
        --lock-path=/run/lock/subsys/nginx \
        --user=nginx \
        --group=nginx \
        --with-pcre \
        --with-http_ssl_module \
        --add-module=/tempDir/nginx-http-flv-module-${HTTP_FLV_MODULE_VERSION} \
    && make && make install \
    && rm -rf /tempDir

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80
EXPOSE 1935

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]