functions =
    ###
    =====================================
    Locations
    =====================================
    ###
    the_log_formats: (formats, tabs = 1)->
        str = ""

        id = 0
        for key, val of formats
            if id > 0
                str += " \n"

                times = 4 * tabs
                str += " " for i in [0...times]

            str += "log_format"
            str += " "
            str += key
            str += " "
            str += val
            str += ";"

            id++

        return str

    the_logs: (log, type, tabs = 1)->
        str = ""

        if type is "access" then str += "access_log"
        else str += "error_log"

        str += " "
        str += log.path

        if log.format then str += " format=#{log.format}"
        if log.buffer then str += " buffer=#{log.buffer}"
        if log.flush then str += " flush=#{log.flush}"
        if log.gzip
            if log.gzip < 1 then log.gzip = 1
            else if log.gzip > 9 then log.gzip = 9
            
            str += " gzip=#{log.gzip}"
        str += ";"

        return str




    ###
    =====================================
    GZIP
    =====================================
    ###
    ###*
     * Создание отформатированнного GZIP Types
     * @param  {Array|String}   gzip_types  - массив доступних типов или строка
     * @param  {Integer}        [tabs=1]    - кол-во табуляций для выравнивания
     * @return {String}                       отформатированная строка
    ###
    the_gzip_types: (types = "*", tabs = 1)->
        str = ""
        str += "gzip_types"
        str += " "

        # Массив
        if types.constructor is Array
            for type, id in types
                if id > 0
                    str += " \n"

                    times = 1 + "gzip_types".length + 4 * tabs
                    str += " " for i in [0...times]

                str += type
        # Строка
        else if types.constructor is String
            str += types
        # Ошибка
        else throw new Error "Wrong type gzip_types. It should be a string or array"

        return str

    ###*
     * Создание отформатированного GZIP comp level
     * @param  {Boolean|Integer}    [level=false]   - сила сжатия
     * @return {String}                               отформатированная строка
    ###
    the_gzip_comp_level: (level = false)->
        str = ""
        unless level then str += "\# "

        str += "gzip_comp_level"
        str += " "

        if level < 1 then level = 1
        else if level > 9 then level = 9

        str += level

        return str

    ###*
     * Создание отформатированного GZIP disable
     * @param  {Boolean|String}     [disable="MSIE [4-6]\."] - строка или регулярное выражение, для каких браузеров не нужно использовать GZIP
     * @return {String}             отформатированная строка
    ###
    the_gzip_disable: (disable = "MSIE [4-6]\\.")->
        str = ""
        unless disable then str += "\# "

        str += "gzip_disable"
        str += " "

        if disable then str += "\"#{disable}\""
        else str += "\"MSIE [4-6]\\.\""

        return str

    ###*
     * Создание отформатированного GZIP buffers
     * @param  {String} [buffers="16 8k"]   - число и размер буферов
     * @return {String}                       отформатированная строка
    ###
    the_gzip_buffers: (buffers = "16 8k")->
        str = ""
        unless buffers then str += "\# "

        str += "gzip_buffers"
        str += " "

        if buffers then str += buffers
        else str += "16 8k"

        return str

    ###*
     * Создание отформатированного GZIP length
     * @param  {Integer}    [length=20]     - минимальная длина ответа, который будет сжиматься gzip
     * @return {String}                       отформатированная строка
    ###
    the_gzip_length: (length = 20)->
        str = ""
        unless length then str += "\# "

        str += "gzip_length"
        str += " "

        if length then str += length
        else str += 20

        return str

    ###*
     * Создание отформатированного GZIP http version
     * @param  {String}     [http_version="1.1"]    - минимальная HTTP-версию запроса, необходимая для сжатия ответа
     * @return {String}                               отформатированная строка
    ###
    the_gzip_http_version: (http_version = "1.1")->
        str = ""
        unless http_version then str += "\# "

        str += "gzip_http_version"
        str += " "

        if http_version then str += http_version
        else str += "1.1"

        return str

    ###*
     * Создание отформатированного GZIP proxied
     * @param  {String}     [http_version="1.1"]    - разрешает или запрещает сжатие ответа методом gzip для проксированных запросов в зависимости от запроса и ответа.
     *                                                off | expired | no-cache | no-store | private | no_last_modified | no_etag | auth | any
     * @return {String}                               отформатированная строка
    ###
    the_gzip_proxied: (proxied = "off")->
        str = ""
        unless proxied then str += "\# "

        str += "gzip_proxied"
        str += " "

        if proxied then str += proxied
        else str += "off"

        return str

    ###
    =====================================
    Locations
    =====================================
    ###
    ###*
     * Создание отформатированного времени кеширования
     * @param  {String|Boolean}     [expires=false] - время кеширования
     * @return {String}                               отформатированная строка
    ###
    the_expires: (expires = false)->
        str = ""
        unless expires then str += "\# "

        str += "expires"
        str += " "

        if expires then str += expires
        else str += "3m"

        return str

    ###*
     * Создает отформатированный список бекендов
     * @param  {Array}          backends    - массив бекендов
     * @param  {Integer}        [tabs=1]    - кол-во табуляций для выравнивания
     * @return {String}                       отформатированная строка
    ###
    the_backends: (backends, tabs = 1)->
        str = ""
        for backend, id in backends
            if id > 0
                str += " \n"

                times = 4 * tabs
                str += " " for i in [0...times]

            str += "server"
            str += " "

            str += backend.address

            if backend.port
                str += ":"
                str += backend.port

            if backend.uri then str += backend.uri

            if backend.weight       then str += " weight=#{backend.weight}"
            if backend.fail_timeout then str += " fail_timeout=#{backend.fail_timeout}"
            if backend.max_fails    then str += " max_fails=#{backend.max_fails}"
            if backend.slow_start   then str += " slow_start=#{backend.slow_start}"
            if backend.backup       then str += " backup"

            str += ";"

        return str
    
    ###*
     * Создает отформатированный список хедеров
     * @param  {Object}         headers     - объект заголовков
     * @param  {Integer}        [tabs=2]    - кол-во табуляций для выравнивания
     * @return {String}                       отформатированная строка
    ###
    the_headers: (headers, tabs = 2)->
        str = ""

        id = 0
        if headers and Object.keys(headers).length > 0

            for key, val of headers
                if id > 0
                    str += " \n"

                    times = 4 * tabs
                    str += " " for i in [0...times]

                str += "add_header"
                str += " "

                str += key
                str += " "
                str += val
                str += ";"
                
                id++

        return str

# Exports
module.exports = functions