var MAIN_TEMPLATE, NginxGenerator, ejs, fs, objectMerge, path, renderFuncs;

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
        formats: [],
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
