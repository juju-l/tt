
		upstream auth-private-srv {
			server 10.0.0.131:5601 weight=1; # 被鉴权服务的后端地址
		}

		include vhost/http/_upstream.cfg; # 引用代理服务定义文件


	server {
		listen 80; #listen 80 default_server; ###listen 443 ssl;
		# server_name	itst.vipex.cc demo.vipex.cc ali.lux.cloud.vipex.cc localhost;
		client_max_body_size 768m; charset utf-8;
				
		set $accessUrl $arg_redirect_url; set $cookieDomain $arg_domain; # 访问服务的URL地址
		set $grantUrl http://gw.vipex.cc/configApi; set $authuiUrl http://auth.vipex.cc; # 授权服务的URL地址
		if ($arg_redirect_url = "") { set $accessUrl $scheme://$host$request_uri; }


		location ~* echo.htm { #输出测试
			default_type 'application/json; charset=UTF-8'; add_header 'Content-Type' 'application/json; charset=UTF-8';
			echo $arg_redirect_url\n$arg_domain $arg_expires; echo "\r\r\r";echo $echo_client_request_headers $echo_request_uri $echo_response_status; echo "\r\r\r";
			echo $request_method $is_args $scheme://$host-$proxy_port $server_name:$server_port $remote_port $http_referer; echo "\r\r\r";
			echo_read_request_body; echo $request_body; echo $http_x_real_ip $http_x_forwarded_for $http_x_forwarded_host;
		}
		location ~* index.htm { # location ~* ^/index.htm\?Authorization=.*$ #设置cookie记录token
			if ( $request_uri ~* index.htm\?Authorization=.*&domain=.*&expires=.*&redirect_url=.*$ ) {
			add_header 'Authorization' 'Bearer $arg_authorization';
			add_header 'Set-Cookie' 'auth=Bearer $arg_authorization;expires=$arg_expires;domain=$cookieDomain;httponly'; # secure; 不需要
			return 302 $accessUrl;
			}
		}
		location / { #鉴权服务的代理	
			#add_header	'Access-Control-Allow-Credentials'	'true';
			add_header	'Access-Control-Allow-Origin'	'*';
			#add_header	'Access-Control-Allow-Methods'	'*';
			add_header	'Access-Control-Allow-Headers'	'*';
			
			auth_request /auth; error_page 401 = @error401;
			proxy_pass http://auth-private-srv;	include vhost/http/proxy.cnt.cfg;
		}
		location /auth { #认证服务的设置
			proxy_set_header Authorization '$cookie_auth'; proxy_pass_header Authorization;
			resolver 10.0.0.11:53 218.30.19.40:53;
			proxy_pass $grantUrl; include vhost/http/proxy.cnt.cfg; #引用代理设置文件
		}		
		location /api/get_remoteIp { #00-_hcAccessor_Test-v0
			proxy_pass http://10.0.0.203:18088/api/get_remoteIp; include vhost/http/proxy.cnt.cfg; #引用代理设置文件
		}
				
location @error401 { #认证失败的登录跳转
		return 302 $authuiUrl/?redirect_url=$accessUrl;
    }


	include vhost/http/_staticfile.cfg; # 引用服务静态文件定义文件

		location /ng_status {
			stub_status on; access_log off; #allow 127.0.0.1; #deny all;
		}

		access_log	logs/$log_name.log _log; error_log	logs/itst.default.loc_err.log;

		error_page	500 502 503 504	/50x.html;
		location = /50x.html {
			root /usr/local/nginx/html;
		}
	}
