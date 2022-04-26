
			upstream kibana-5601 {
				server 10.0.0.131:5601 weight=1;
			}

			include vhost/http/_upstream.cfg;


	server {
		#listen 80 default_server;
		listen 80; ###listen 443 ssl;
		###server_name _;
		server_name		itst.vipex.cc		itst.vipex.cc	ali.lux.cloud.vipex.cc	localhost;
		client_max_body_size 768m;
		charset utf-8;


		location /echo.htm { # http://10.0.0.131/echo.htm?param=returnValue
			default_type 'application/json; charset=UTF-8';
			add_header 'Content-Type' 'application/json; charset=UTF-8';
			echo $scheme://$host $http_host :$server_port $server_name $request_uri $request_method $is_args $remote_port $server_port $http_referer;
			echo $http_host $http_port $http_x_forwarded_for $proxy_host $proxy_port;
			echo "\r"; echo_read_request_body; echo $request_body; echo "\r";
			echo "\r\r\r";echo $echo_request_body $echo_client_request_method $echo_client_request_headers $echo_request_uri $echo_response_status;
		}

		# top.location.href="http://10.0.0.131:86/index.htm?Authorization="+response.token.access_token+"&expires="
		# +response.expires.replace(/\ /g,"_");
		location /index.htm {
			add_header 'Authorization' 'Bearer $arg_authorization';
			add_header 'Set-Cookie' 'auth=Bearer $arg_authorization;expires=$arg_expires;domain=dash.vipex.cc;httponly'; # secure; 不需要
			return 302 http://10.0.0.203:8080; #http://10.0.0.131:86/;
		}
		#location ~* ^/index.htm\?Authorization=.*$ {
		#	add_header 'Authorization' 'Bearer $arg_authorization';
		#	add_header 'Set-Cookie' 'auth=Bearer $arg_authorization';
		#	#proxy_pass http://kibana-5601;
		#	return 302 http://10.0.0.131:86/;
		#}
		location / {
			#add_header 'Access-Control-Allow-Credentials' 'true';
			add_header 'Access-Control-Allow-Origin'      '*';
			#add_header 'Access-Control-Allow-Methods'     '*';
			add_header 'Access-Control-Allow-Headers'     '*';
			
			auth_request /auth; error_page 401 = @error401;
			proxy_pass http://kibana-5601;	include vhost/http/proxy.cnt.cfg;
		}
		location /auth {
			proxy_set_header Authorization '$cookie_auth';
			proxy_pass_header Authorization;
			proxy_pass http://10.0.0.203:8080/configApi;	include vhost/http/proxy.cnt.cfg;
		}
		
location @error401 {
		return 302 http://auth.vipex.cc/xXsys/auth; #http://10.0.0.203:8080/loginApi?user=sys&pswd=54321;
    }


	include vhost/http/_staticfile.cfg;

		location /ng_status {
			stub_status on; access_log off;			#allow 127.0.0.1;			#deny all;
		}

		access_log	logs/$log_name.log _log;
		error_log	logs/itst.default.loc_err.log;

		error_page   500 502 503 504	/50x.html;
		location = /50x.html {
			root /usr/local/nginx/html;
		}
	}
