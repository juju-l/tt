FROM centos:latest

MAINTAINER lj@vipex.cc# docker build --no-cache -t ng1.xx.loc:v7.61 . 2>&1 | tee nginx-v7.61.log
	RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup	#下载阿里源
	RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	#修改时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime



		RUN groupadd www && useradd -s /sbin/nologin -g www www
		RUN mkdir -p /usr/local/nginx/ssl /usr/local/nginx/client_body_temp /usr/local/nginx/proxy_temp /usr/local/nginx/fastcgi_temp /usr/local/nginx/uwsgi_temp /usr/local/nginx/scgi_temp
		RUN yum -y install wget gcc make openssl-devel net-tools nmap

			# wget -c ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre2-10.33.tar.gz
		ADD pcre2-10.33.tar.gz /tmp/
		WORKDIR /tmp/pcre2-10.33
		RUN ./configure --prefix="/usr/local/pcre"

			# wget -c http://zlib.net/zlib-1.2.11.tar.gz
		ADD zlib-1.2.11.tar.gz /tmp/
		WORKDIR /tmp/zlib-1.2.11
		RUN ./configure --prefix="/usr/local/zlib"

			# wget -c https://codeload.github.com/openresty/echo-nginx-module/tar.gz/v0.61
		ADD echo-nginx-module-0.61.tar.gz /tmp/	

			# wget -c http://nginx.org/download/nginx-1.16.0.tar.gz
		ADD nginx-1.16.0.tar.gz /tmp/
		WORKDIR /tmp/nginx-1.16.0
		RUN ./configure --user=www --group=www --with-threads \
			--with-http_realip_module \
			--with-http_stub_status_module --with-http_ssl_module --with-http_v2_module --with-http_auth_request_module \
			--http-client-body-temp-path=/usr/local/nginx/client_body_temp --http-proxy-temp-path=/usr/local/nginx/proxy_temp \
			--http-fastcgi-temp-path=/usr/local/nginx/fastcgi_temp --http-uwsgi-temp-path=/usr/local/nginx/uwsgi_temp --http-scgi-temp-path=/usr/local/nginx/scgi_temp \
			--with-stream --with-debug \
			--add-module=/tmp/echo-nginx-module-0.61
		RUN make && make install && ln -sf /usr/local/nginx/sbin/nginx /usr/bin/nginx
		
WORKDIR /usr/local/nginx

		RUN mkdir -p conf/vhost/http conf/vhost/tcp && mv conf/nginx.conf conf/nginx.conf.bak
		COPY nginx.conf conf/nginx.conf
		COPY default.conf conf/vhost/default.conf		
		COPY rNginx.sh .



EXPOSE 80 8080 443
#特殊配置导入 	COPY dev conf/vhost/http/ COPY log.sh logs/log.sh
# 清理源码碎片文件
RUN rm -rf /tmp/* /var/cache/yum/* && yum clean all && chmod +x rNginx.sh && cat conf/nginx.conf
CMD ["./rNginx.sh"]

#docker run --name nginx -d -it -p 80:80 -p 8080:8080 -p 443:443 -v /stg/wEnv/NginxSSL:/usr/local/nginx/ssl -v /stg/wEnv/vhost:/usr/local/nginx/conf/vhost -v /stg/wLog/nginx:/usr/local/nginx/logs -v /stg/wRoot/ui0.xasea2.loc:/usr/local/nginx/html --restart always reg.vipex.cc:80/jdg/ng1.xx.loc:v7.61
###使用宿主网络
#docker run --name nginx -d -it --net host -v /stg/wEnv/NginxSSL:/usr/local/nginx/ssl -v /stg/wEnv/vhost:/usr/local/nginx/conf/vhost -v /stg/wLog/nginx:/usr/local/nginx/logs -v /stg/wRoot/ui0.xasea2.loc:/usr/local/nginx/html --restart always reg.vipex.cc:80/jdg/ng1.xx.loc:v7.61
#access_log	logs/$log_name.log _log; #main;
#curl -s --request POST --url http://10.0.0.203:8080 --header 'Cache-Control: no-cache' --header 'Connection: keep-alive' --header 'accept-encoding: gzip, deflate' --header 'cache-control: no-cache' --form 'pgsql=Host=192.168.0.106;Port=5432;Username=postgres;Password=123456;Database=_log_nginx;Passfile=' --form "logfile=@/stg/wLog/nginx/$date_l.log"
#/bin/sh -c "/usr/local/nginx/logs/log.sh 2019-05-01 11-00.log“
#cron - > 00 */1 * * * /bin/sh -c "/stg/wLog/nginx/log.sh"
