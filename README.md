1. Add ngx_http_js_module import in /etc/nginx/nginx.conf
```
load_module modules/ngx_http_js_module.so;

events {
worker_connections  1024;
}
```
2. sudo mkdir /etc/nginx/njs
3. sudo cp ./conf.d/default.conf /etc/nginx/conf.d/ && sudo cp ./njs/dmr.js /etc/nginx/njs/ && sudo nginx -s reload && sudo tail -f /var/log/nginx/access.log -f /var/log/nginx/error.log
