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
        formats: 
            "compression":  "
                            '$remote_addr - $remote_user [$time_local] 
                            \"$request\" $status $bytes_sent 
                            \"$http_referer\" \"$http_user_agent\" \"$gzip_ratio\"'
                            "
        access: 
            path: "/var/nginx.acc.test.log"
            format: "compression"
            buffer: "32k"
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
                # uri:            false
                # weight:         7
                # backup:         false
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
            "application/json"
            "application/x-javascript"
            "text/xml"
            "application/xml"
            "application/xml+rss"
            "text/javascript"
            "application/javascript"
        ]
}

conf = ngen.render()
fs.writeFileSync path.join(__dirname, "test_nginx.conf"), conf