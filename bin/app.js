var MAIN_TEMPLATE, NginxGenerator, conf, ejs, fs, nginx, objectMerge, path, renderFuncs;

fs = require('fs');

path = require('path');

ejs = require('ejs');

objectMerge = require('object-merge');

renderFuncs = require(path.join(__dirname, '/libs/renderFuncs.js'));

MAIN_TEMPLATE = fs.readFileSync(path.join(__dirname, "/templates/_nginx.conf")).toString();

NginxGenerator = (function() {
  function NginxGenerator(opts) {
    if (opts == null) {
      opts = {};
    }
    this.renderOpts = {

      /*
      =====================================
      Locations
      =====================================
       */
      listen: 80,
      server_name: [],
      logs: {
        log_formats: [],
        access: false,
        error: false
      },

      /*
      =====================================
      GZIP
      =====================================
       */
      gzip: {
        types: [],
        buffers: false,
        disable: "MSIE [4-6]\\.",
        min_length: false,
        http_version: false,
        proxied: false,
        vary: true,
        level: false
      },

      /*
      =====================================
      Locations
      =====================================
       */
      statics: [],
      static_files: [],
      proxys: [],

      /*
      =====================================
      Globals
      =====================================
       */
      globals: {
        headers: {}
      },
      $func: renderFuncs
    };
    this.renderOpts = objectMerge(this.renderOpts, opts);
    this.$addGlobalsToLocations();
  }

  NginxGenerator.prototype.$addGlobalsToLocations = function() {
    var i, id, j, k, len, len1, len2, location, ref, ref1, ref2, results;
    ref = this.renderOpts.statics;
    for (id = i = 0, len = ref.length; i < len; id = ++i) {
      location = ref[id];
      this.renderOpts.statics[id] = objectMerge(this.renderOpts.globals, location);
    }
    ref1 = this.renderOpts.static_files;
    for (id = j = 0, len1 = ref1.length; j < len1; id = ++j) {
      location = ref1[id];
      this.renderOpts.static_files[id] = objectMerge(this.renderOpts.globals, location);
    }
    ref2 = this.renderOpts.proxys;
    results = [];
    for (id = k = 0, len2 = ref2.length; k < len2; id = ++k) {
      location = ref2[id];
      results.push(this.renderOpts.proxys[id] = objectMerge(this.renderOpts.globals, location));
    }
    return results;
  };

  NginxGenerator.prototype.render = function() {
    return ejs.render(MAIN_TEMPLATE, this.renderOpts);
  };

  return NginxGenerator;

})();

module.exports = {
  NginxGenerator: NginxGenerator
};

nginx = new NginxGenerator({
  server_name: ["test.com", "*.test.com"],
  logs: {
    log_formats: {
      "compression": "'$remote_addr - $remote_user [$time_local] \"$request\" $status $bytes_sent \"$http_referer\" \"$http_user_agent\" \"$gzip_ratio\"'"
    },
    access: {
      path: "/var/nginx.acc.test.log",
      format: "compression",
      buffer: "32k",
      gzip: 4,
      flush: "5m"
    },
    error: {
      path: "/var/nginx.err.test.log"
    }
  },
  statics: [
    {
      location: "/public",
      root: "/apps/nodejs/test.com/",
      expires: "30d"
    }
  ],
  static_files: [
    {
      location: "/favicon.ico",
      root: "/apps/nodejs/test.com/favicon",
      expires: "30d"
    }
  ],
  proxys: [
    {
      location: "/",
      backends_name: "backend",
      backends: [
        {
          address: "127.0.0.1",
          port: 8080
        }
      ]
    }
  ],
  globals: {
    headers: {
      "X-Create-By": "NGINXER"
    },
    trust_proxy: true
  },
  gzip: {
    types: ["text/plain", "text/css", "application/json", "application/x-javascript", "text/xml", "application/xml", "application/xml+rss", "text/javascript", "application/javascript"]
  }
});

conf = nginx.render();

fs.writeFileSync(path.join(__dirname, "nginx.conf"), conf);
