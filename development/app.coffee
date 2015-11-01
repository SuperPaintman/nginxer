# Requires
fs              = require 'fs'
path            = require 'path'

ejs             = require 'ejs'
objectMerge     = require 'object-merge'

renderFuncs     = require path.join __dirname, '/libs/renderFuncs.js'

# Templates
MAIN_TEMPLATE = fs.readFileSync(path.join __dirname, "/templates/_nginx.conf").toString()

class NginxGenerator
    constructor: (opts = {})->
        # Defaults
        @renderOpts =
            ###
            =====================================
            Locations
            =====================================
            ###
            listen: 80
            server_name: []

            logs:
                log_formats: []
                access: false
                error: false

            ###
            =====================================
            GZIP
            =====================================
            ###
            gzip:
                types: []

                buffers: false

                disable: "MSIE [4-6]\\."

                min_length: false

                http_version: false

                proxied: false

                vary: true
                level: false

            ###
            =====================================
            Locations
            =====================================
            ###
            statics: []

            static_files: []

            proxys: []

            ###
            =====================================
            Globals
            =====================================
            ###
            globals:
                headers: {}


            $func: renderFuncs

        # Merge
        @renderOpts = objectMerge @renderOpts, opts
        do @.$addGlobalsToLocations

        # console.log @renderOpts

    $addGlobalsToLocations: ->
        for location, id in @renderOpts.statics
            @renderOpts.statics[id] = objectMerge @renderOpts.globals, location

        for location, id in @renderOpts.static_files
            @renderOpts.static_files[id] = objectMerge @renderOpts.globals, location

        for location, id in @renderOpts.proxys
            @renderOpts.proxys[id] = objectMerge @renderOpts.globals, location

    render: -> ejs.render MAIN_TEMPLATE, @renderOpts

# Exports
module.exports = {
    NginxGenerator
}

nginx = new NginxGenerator {
    # Def
    server_name: [
        "test.com"
        "*.test.com"
    ]

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

conf = nginx.render()

fs.writeFileSync path.join(__dirname, "nginx.conf"), conf