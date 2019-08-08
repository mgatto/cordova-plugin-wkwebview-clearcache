WK Cache Clear
=============

WKCacheClear selectively clears the WkWebView cache for Cordova 9 running on iOS 9 or above. 

Derived from Anrip Wong's CacheClear plugin https://github.com/anrip/cordova-plugin-cache-clear. This plugin was rewritten to specifically support WkWebView on iOS, whose cache clearing mechanics differ from UIWebView. Android support was not considered, since WkWebView is specific to iOS.


Installation
======
Using the standard Cordova CLI:

<pre>
cordova plugin add https://github.com/mgatto/cordova-plugin-wkwebview-clearcache.git
</pre>

Usage
====
```javascript
document.addEventListener('deviceready', function() {
    window.WkCacheClear({delete: ['cookies','assets']}, () => '', (error) => '');
});
```

Options
-------

* `delete`: an array of plain-text aliases for `WkWebSiteDataType` constants:

    **Supported:**
    * *(included automatically)* WKWebsiteDataTypeMemoryCache
    * `cookies` => WKWebsiteDataTypeCookies 
    * `assets` => WKWebsiteDataTypeDiskCache (HTML, JS and image files cached from the Cordova bundle)
        
    **Unsupported:**
    - WKWebsiteDataTypeOfflineWebApplicationCache
    - WKWebsiteDataTypeLocalStorage
    - WKWebsiteDataTypeSessionStorage
    - WKWebsiteDataTypeIndexedDBDatabases
    - WKWebsiteDataTypeWebSQLDatabases
