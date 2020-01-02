var exec = require('cordova/exec');

/**
 * Usage:
 * 
 * window.WkCacheClear({'domain': 'example.com', delete: ['cookies','assets']}, () => '', (error) => '');
 * 
 * options object is required.
 *   domain setting is required
 *   delete setting (array) is optional. Allowed values are an empty array (but, why?), 'cookies' and/or 'assets'.
 * 
 */ 
var WkCacheClear = function (options, success, error) {
    if ( !options.hasOwnProperty('domain')) {
        error('option: "domain" is required');
    } 
    else {
        exec(success, error, 'WkCacheClear', 'task', [options]);
    }
};

module.exports = WkCacheClear;
