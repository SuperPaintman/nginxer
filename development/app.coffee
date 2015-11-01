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
            listen: 80
            server_name: []

            logs:
                log_formats: 
                    "compression":  "
                                    '$remote_addr - $remote_user [$time_local] 
                                    \"$request\" $status $bytes_sent 
                                    \"$http_referer\" \"$http_user_agent\" \"$gzip_ratio\"'
                                    "
                access: 
                    path: "/var/nginx.acc.test.redhex.ru.log"
                    format: "compression"
                    buffer: "32k"
                    gzip: 9
                    flush: "5m"
                error:  
                    path: "/var/nginx.err.test.redhex.ru.log"

            ###
            =====================================
            GZIP
            =====================================
            ###
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

                buffers: "16 8k"

                disable: false

                min_length: 20

                http_version: false

                proxied: false

                vary: true
                level: 9

            ###
            =====================================
            Locations
            =====================================
            ###
            statics: [
                location:   "/public"
                root:       "/apps/nodejs/test.redhex.ru"
                expires:    "24d"
            ]

            static_files: [
                location:   "/favicon.ico"
                root:       "/apps/nodejs/$sireDir/bin/public/favicon"
                expires:    "24d"
            ]

            proxys: [
                location:       "/"
                expires:        "24d"
                headers:
                    "a": "b"
                    "c": "v"
                    "e": "q"
                trust_proxy:    true

                backends_name:  "backend"
                backends:
                    [
                        address:        "127.0.0.1"
                        port:           1337
                        uri:            false
                        weight:         7
                        backup:         false
                    ,
                        address:        "127.0.0.1"
                        port:           1337
                        uri:            false
                        weight:         7

                        fail_timeout:   3
                        max_fails:      "30s"
                        backup:         false
                    ]
            ]

            ###
            =====================================
            Globals
            =====================================
            ###
            globals:
                headers:
                    "X-Powered-By": "PHP/5.5.28"


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

nginx = new NginxGenerator()
conf = nginx.render()

fs.writeFileSync path.join(__dirname, "nginx.conf"), conf