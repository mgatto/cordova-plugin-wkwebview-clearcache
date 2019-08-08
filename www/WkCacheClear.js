var exec = require('cordova/exec');

// Usage
// window.WkCacheClear({delete: ['cookies','assets'], cookieDomain: 'example.com'}, () => '', (error) => '');

var WkCacheClear = function (options, success, error) {
    exec(success, error, 'WkCacheClear', 'task', [options]);
};

module.exports = WkCacheClear;
