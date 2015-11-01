# Generator for nginx configuration files via API

------------------------------------

## Installation
### NPM
```sh
npm install nginxer --save-dev
```

------------------------------------

## Usage

~~~coffee
# Requires
fs              = require 'fs'
path            = require 'path'

nginxer         = require path.join __dirname, '../app.js'

# Init
NginxGenerator  = nginxer.NginxGenerator

ngen = new NginxGenerator {
    # Def
    server_name: [
        "test.com"
        "*.test.com"
    ]

    # Logs
    logs:
        log_formats: 
            "compression":  "
                            '$remote_addr - $remote_user [$time_local] 
                            \"$request\" $status $bytes_sent 
                            \"$http_referer\" \"$http_user_agent\" \"$gzip_ratio\"'
                            "
        access: 
            path: "/var/nginx.acc.test.log"
            format: "compression"
            gzip: 4
            flush: "5m"
        error:  
            path: "/var/nginx.err.test.log"

    # Locations
    statics: [
        location:   "/public"
        root:       "/apps/nodejs/test.com/"
        expires:    "30d"
    ]

    # Static Files
    static_files: [
        location:   "/favicon.ico"
        root:       "/apps/nodejs/test.com/favicon"
        expires:    "30d"
    ]

    # Proxy
    proxys: [
        location:       "/"
        # expires:        "3s"

        backends_name:  "backend"
        backends:
            [
                address:        "127.0.0.1"
                port:           8080
            ]
    ]

    # Globals
    globals:
        headers:
            "X-Create-By": "NGINXER"

        trust_proxy:    true

    # GZIP
    gzip:
        types: [
            "text/plain"
            "text/css"
        ]
}

conf = ngen.render()
fs.writeFileSync path.join(__dirname, "test_nginx.conf"), conf
~~~

and output `test_nginx.conf` file:

~~~nginx
upstream backend {
    server 127.0.0.1:8080;
}

server {
    listen       80;
    server_name  test.com *.test.com;

    log_format   compression '$remote_addr - $remote_user [$time_local] "$request" $status $bytes_sent "$http_referer" "$http_user_agent" "$gzip_ratio"';
    access_log   /var/nginx.acc.test.log format=compression buffer=32k flush=5m gzip=4;
    error_log    /var/nginx.err.test.log;

    
    #####################################
    # GZIP
    #####################################
    gzip on;
    gzip_vary on;

    gzip_disable "MSIE [4-6]\.";
    gzip_types text/plain 
               text/css 
               application/json 
               application/x-javascript 
               text/xml 
               application/xml 
               application/xml+rss 
               text/javascript 
               application/javascript;
    # gzip_buffers 16 8k;
    # gzip_length 20;
    # gzip_http_version 1.1;
    # gzip_proxied off;
    # gzip_comp_level 1;


    #####################################
    # Locations
    #####################################
    # Static
    location /public {
        # Headers
        add_header X-Create-By NGINXER;

        # Trust Proxy
        add_header Host $host;
        add_header X-Real-IP $remote_addr;
        add_header X-Forwarded-For $proxy_add_x_forwarded_for;
        

        expires 30d;
        root /apps/nodejs/test.com/;
    }
    
    # Static Files
    location /favicon.ico {
        # Headers
        add_header X-Create-By NGINXER;
        
        # Trust Proxy
        add_header Host $host;
        add_header X-Real-IP $remote_addr;
        add_header X-Forwarded-For $proxy_add_x_forwarded_for;
        
        expires 30d;
        root /apps/nodejs/test.com/favicon;
    }
    
    # Proxy
    location / {
        # Headers
        add_header X-Create-By NGINXER;
        
        # Trust Proxy
        add_header Host $host;
        add_header X-Real-IP $remote_addr;
        add_header X-Forwarded-For $proxy_add_x_forwarded_for;
        
        # expires 3m;
        proxy_pass http://backend;
    }
}
~~~

------------------------------------

## API
### Constructor
* `Integer`         **listen**
* `Array|String`    **server_name**

* `Object`      **logs**
    * `Array`       **formats**
    * `Object`      **access**
    * `Object`      **error**

* `Object`      **gzip**
    * `Array`       **types**
    * `String`      **buffers**
    * `String`      **disable**
    * `Integer`     **min_length**
    * `String`      **http_version**
    * `String`      **proxied**
    * `Boolean`     **vary**
    * `Integer`     **level**

* `Array`       **statics**
* `Array`       **static_files**
* `Array`       **proxys**

* `Object`      **globals**


------------------------------------

## Build form coffee source
### Build project
The source code in the folder **development**. They should be compiled in the **bin** folder

```sh
# With watching
gulp
```

or

```sh
gulp build
```

### Build gulpfile

```sh
coffee -c gulpfile.coffee
```

------------------------------------

## Roadmap
### Templater
* [`ERROR`] Remove extra whitespaces and new lines

### Plugins
* Gulp plugun
* Yeolman generator

### Configs
* Configs for [http://nginx.org/en/docs/http/ngx_http_geoip_module.html](ngx_http_geoip_module)
* Configs for [http://nginx.org/en/docs/http/ngx_http_access_module.html](ngx_http_access_module)
* Configs for [http://nginx.org/en/docs/http/ngx_http_v2_module.html](ngx_http_v2_module)
* Configs for [http://nginx.org/en/docs/http/ngx_http_auth_request_module.html](ngx_http_auth_request_module)
* Configs for [http://nginx.org/en/docs/http/ngx_http_gzip_static_module.html](ngx_http_gzip_static_module)
* Configs for [http://nginx.org/en/docs/http/ngx_http_limit_conn_module.html](ngx_http_limit_conn_module)
* Configs for [http://nginx.org/en/docs/http/ngx_http_limit_req_module.html](ngx_http_limit_req_module)
* Configs for [http://nginx.org/en/docs/http/ngx_http_map_module.html](ngx_http_map_module)
* Configs for [http://nginx.org/en/docs/http/ngx_http_split_clients_module.html](ngx_http_split_clients_module)
* `[?]` Configs for [http://nginx.org/en/docs/http/ngx_http_status_module.html](ngx_http_status_module)
* `[?]` Configs for [http://nginx.org/ru/docs/http/ngx_http_proxy_module.html](ngx_http_proxy_module)