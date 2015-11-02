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
            server_name: [
                "text.com"
                "www.text.com"
            ]

            logs:
                formats:    null

                access:
                    path:   "/tmp/nginx.test.log"
                error:
                    path:   "/tmp/nginx.test.log"

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
            statics: null

            static_files: null

            proxys: null

            ###
            =====================================
            Globals
            =====================================
            ###
            globals: null


            $func: renderFuncs

        # Merge
        @.$mergeOpts opts
        do @.$addGlobalsToLocations

        # console.log @renderOpts
    
    $mergeOpts: (opts)->
        @renderOpts = objectMerge @renderOpts, opts

        # Clear server_name
        if opts?.server_name
            @renderOpts.server_name = opts.server_name

        # Clear gzip_types
        if opts?.gzip?.types
            @renderOpts.gzip.types = opts.gzip.types

    $addGlobalsToLocations: ->
        if @renderOpts.statics
            for location, id in @renderOpts.statics
                @renderOpts.statics[id] = objectMerge @renderOpts.globals, location

        if @renderOpts.static_files
            for location, id in @renderOpts.static_files
                @renderOpts.static_files[id] = objectMerge @renderOpts.globals, location

        if @renderOpts.proxys
            for location, id in @renderOpts.proxys
                @renderOpts.proxys[id] = objectMerge @renderOpts.globals, location

    render: -> ejs.render MAIN_TEMPLATE, @renderOpts

# Exports
module.exports = {
    NginxGenerator
}