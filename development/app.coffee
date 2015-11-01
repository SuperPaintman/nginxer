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
                formats: []
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