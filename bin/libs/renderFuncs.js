var functions;

functions = {

  /*
  =====================================
  Locations
  =====================================
   */

  /**
   * Создание отформатированнного log_format
   * @param  {Object}     formats     - объект с форматами логов
   * @param  {Integer}    [tabs=1]    - кол-во табуляций для выравнивания
   * @return {String}                   отформатированная строка
   */
  the_log_formats: function(formats, tabs) {
    var i, id, j, k, key, ref, ref1, str, times, val;
    if (tabs == null) {
      tabs = 1;
    }
    str = "";
    id = 0;
    for (key in formats) {
      val = formats[key];
      if (id > 0) {
        str += " \n";
        times = 4 * tabs;
        for (i = j = 0, ref = times; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
          str += " ";
        }
      }
      str += "log_format";
      str += " ";
      times = 4 - "log_format".length % 4;
      for (i = k = 0, ref1 = times; 0 <= ref1 ? k < ref1 : k > ref1; i = 0 <= ref1 ? ++k : --k) {
        str += " ";
      }
      str += key;
      str += " ";
      str += val;
      str += ";";
      id++;
    }
    return str;
  },

  /**
   * Создание отформатированнного access_log / error_log
   * @param  {Object}     log         - данные логирования
   * @param  {String}     type        - тип лога access / error
   * @param  {Integer}    [tabs=1]    - кол-во табуляций для выравнивания
   * @return {String}                   отформатированная строка
   */
  the_logs: function(log, type, tabs) {
    var i, j, k, ref, ref1, str, times;
    if (tabs == null) {
      tabs = 1;
    }
    str = "";
    if (!(log != null ? log.path : void 0)) {
      str += "\# ";
    }
    if (type === "access") {
      str += "access_log";
      times = 4 - "access_log".length % 4;
      for (i = j = 0, ref = times; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        str += " ";
      }
    } else {
      str += "error_log";
      times = 4 - "error_log".length % 4;
      for (i = k = 0, ref1 = times; 0 <= ref1 ? k < ref1 : k > ref1; i = 0 <= ref1 ? ++k : --k) {
        str += " ";
      }
    }
    str += " ";
    if (log.path) {
      str += log.path;
    } else {
      str += "tmp/nginx." + type + ".log";
    }
    if (log.format) {
      str += " format=" + log.format;
    }
    if (log.buffer) {
      str += " buffer=" + log.buffer;
    }
    if (log.flush) {
      str += " flush=" + log.flush;
    }
    if (log.gzip) {
      if (log.gzip < 1) {
        log.gzip = 1;
      } else if (log.gzip > 9) {
        log.gzip = 9;
      }
      str += " gzip=" + log.gzip;
    }
    str += ";";
    return str;
  },

  /*
  =====================================
  GZIP
  =====================================
   */

  /**
   * Создание отформатированнного GZIP Types
   * @param  {Array|String}   gzip_types  - массив доступних типов или строка
   * @param  {Integer}        [tabs=1]    - кол-во табуляций для выравнивания
   * @return {String}                       отформатированная строка
   */
  the_gzip_types: function(types, tabs) {
    var i, id, j, k, len, ref, str, times, type;
    if (types == null) {
      types = "*";
    }
    if (tabs == null) {
      tabs = 1;
    }
    str = "";
    str += "gzip_types";
    str += " ";
    if (types.constructor === Array) {
      for (id = j = 0, len = types.length; j < len; id = ++j) {
        type = types[id];
        if (id > 0) {
          str += " \n";
          times = 1 + "gzip_types".length + 4 * tabs;
          for (i = k = 0, ref = times; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
            str += " ";
          }
        }
        str += type;
      }
    } else if (types.constructor === String) {
      str += types;
    } else {
      throw new Error("Wrong type gzip_types. It should be a string or array");
    }
    return str;
  },

  /**
   * Создание отформатированного GZIP comp level
   * @param  {Boolean|Integer}    [level=false]   - сила сжатия
   * @return {String}                               отформатированная строка
   */
  the_gzip_comp_level: function(level) {
    var str;
    if (level == null) {
      level = false;
    }
    str = "";
    if (!level) {
      str += "\# ";
    }
    str += "gzip_comp_level";
    str += " ";
    if (level < 1) {
      level = 1;
    } else if (level > 9) {
      level = 9;
    }
    str += level;
    return str;
  },

  /**
   * Создание отформатированного GZIP disable
   * @param  {Boolean|String}     [disable="MSIE [4-6]\."] - строка или регулярное выражение, для каких браузеров не нужно использовать GZIP
   * @return {String}             отформатированная строка
   */
  the_gzip_disable: function(disable) {
    var str;
    if (disable == null) {
      disable = "MSIE [4-6]\\.";
    }
    str = "";
    if (!disable) {
      str += "\# ";
    }
    str += "gzip_disable";
    str += " ";
    if (disable) {
      str += "\"" + disable + "\"";
    } else {
      str += "\"MSIE [4-6]\\.\"";
    }
    return str;
  },

  /**
   * Создание отформатированного GZIP buffers
   * @param  {String} [buffers="16 8k"]   - число и размер буферов
   * @return {String}                       отформатированная строка
   */
  the_gzip_buffers: function(buffers) {
    var str;
    if (buffers == null) {
      buffers = "16 8k";
    }
    str = "";
    if (!buffers) {
      str += "\# ";
    }
    str += "gzip_buffers";
    str += " ";
    if (buffers) {
      str += buffers;
    } else {
      str += "16 8k";
    }
    return str;
  },

  /**
   * Создание отформатированного GZIP length
   * @param  {Integer}    [length=20]     - минимальная длина ответа, который будет сжиматься gzip
   * @return {String}                       отформатированная строка
   */
  the_gzip_length: function(length) {
    var str;
    if (length == null) {
      length = 20;
    }
    str = "";
    if (!length) {
      str += "\# ";
    }
    str += "gzip_length";
    str += " ";
    if (length) {
      str += length;
    } else {
      str += 20;
    }
    return str;
  },

  /**
   * Создание отформатированного GZIP http version
   * @param  {String}     [http_version="1.1"]    - минимальная HTTP-версию запроса, необходимая для сжатия ответа
   * @return {String}                               отформатированная строка
   */
  the_gzip_http_version: function(http_version) {
    var str;
    if (http_version == null) {
      http_version = "1.1";
    }
    str = "";
    if (!http_version) {
      str += "\# ";
    }
    str += "gzip_http_version";
    str += " ";
    if (http_version) {
      str += http_version;
    } else {
      str += "1.1";
    }
    return str;
  },

  /**
   * Создание отформатированного GZIP proxied
   * @param  {String}     [http_version="1.1"]    - разрешает или запрещает сжатие ответа методом gzip для проксированных запросов в зависимости от запроса и ответа.
   *                                                off | expired | no-cache | no-store | private | no_last_modified | no_etag | auth | any
   * @return {String}                               отформатированная строка
   */
  the_gzip_proxied: function(proxied) {
    var str;
    if (proxied == null) {
      proxied = "off";
    }
    str = "";
    if (!proxied) {
      str += "\# ";
    }
    str += "gzip_proxied";
    str += " ";
    if (proxied) {
      str += proxied;
    } else {
      str += "off";
    }
    return str;
  },

  /*
  =====================================
  Locations
  =====================================
   */

  /**
   * Создание отформатированного времени кеширования
   * @param  {String|Boolean}     [expires=false] - время кеширования
   * @return {String}                               отформатированная строка
   */
  the_expires: function(expires) {
    var str;
    if (expires == null) {
      expires = false;
    }
    str = "";
    if (!expires) {
      str += "\# ";
    }
    str += "expires";
    str += " ";
    if (expires) {
      str += expires;
    } else {
      str += "3m";
    }
    return str;
  },

  /**
   * Создает отформатированный список бекендов
   * @param  {Array}          backends    - массив бекендов
   * @param  {Integer}        [tabs=1]    - кол-во табуляций для выравнивания
   * @return {String}                       отформатированная строка
   */
  the_backends: function(backends, tabs) {
    var backend, i, id, j, k, len, ref, str, times;
    if (tabs == null) {
      tabs = 1;
    }
    str = "";
    for (id = j = 0, len = backends.length; j < len; id = ++j) {
      backend = backends[id];
      if (id > 0) {
        str += " \n";
        times = 4 * tabs;
        for (i = k = 0, ref = times; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
          str += " ";
        }
      }
      str += "server";
      str += " ";
      str += backend.address;
      if (backend.port) {
        str += ":";
        str += backend.port;
      }
      if (backend.uri) {
        str += backend.uri;
      }
      if (backend.weight) {
        str += " weight=" + backend.weight;
      }
      if (backend.fail_timeout) {
        str += " fail_timeout=" + backend.fail_timeout;
      }
      if (backend.max_fails) {
        str += " max_fails=" + backend.max_fails;
      }
      if (backend.slow_start) {
        str += " slow_start=" + backend.slow_start;
      }
      if (backend.backup) {
        str += " backup";
      }
      str += ";";
    }
    return str;
  },

  /**
   * Создает отформатированный список хедеров
   * @param  {Object}         headers     - объект заголовков
   * @param  {Integer}        [tabs=2]    - кол-во табуляций для выравнивания
   * @return {String}                       отформатированная строка
   */
  the_headers: function(headers, tabs) {
    var i, id, j, key, ref, str, times, val;
    if (tabs == null) {
      tabs = 2;
    }
    str = "";
    id = 0;
    if (headers && Object.keys(headers).length > 0) {
      for (key in headers) {
        val = headers[key];
        if (id > 0) {
          str += " \n";
          times = 4 * tabs;
          for (i = j = 0, ref = times; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
            str += " ";
          }
        }
        str += "add_header";
        str += " ";
        str += key;
        str += " ";
        str += val;
        str += ";";
        id++;
      }
    }
    return str;
  }
};

module.exports = functions;
