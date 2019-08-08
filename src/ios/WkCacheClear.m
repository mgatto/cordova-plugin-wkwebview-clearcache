#import "WkCacheClear.h"
#import <WebKit/WKWebsiteDataStore.h>

@implementation WkCacheClear

@synthesize command;

- (void)task:(CDVInvokedUrlCommand *)command
{
    NSLog(@"Cordova iOS WkCacheClear() called.");


// @TODO test for iOS 9 or above

    self.command = command;

    NSArray* arguments = command.arguments;
    if ([command.arguments count] > 0) {
        NSDictionary* options = [arguments objectAtIndex:0];
        NSArray* cachesToDelete = [options objectForKey:@"delete"];
    }

    [self.commandDelegate runInBackground:^{

        NSMutableSet *websiteDataTypes = [NSMutableSet setWithArray:@[WKWebsiteDataTypeMemoryCache,WKWebsiteDataTypeOfflineWebApplicationCache]];

//@TODO cachesToDelete may not exist when the optons array is not passed!
        if ([cachesToDelete containsObject:@"cookies"]) {

            // only delete OUR cookies!!
            WKWebsiteDataStore *dataStore = [WKWebsiteDataStore,WKWebsiteDataTypeCookies];
            [dataStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]  // allWebsiteDataTypes
                             completionHandler:^(NSArray<WKWebsiteDataRecord *> * _Nonnull records) {
                                 for (WKWebsiteDataRecord *record  in records) {
                                     if ( [record.displayName containsString:@"ewinerysolutions.com"]) {
                                         [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                                                   forDataRecords:@[record]
                                                                                completionHandler:^{
                                                                                    NSLog(@"Cookies for %@ deleted successfully", record.displayName);
                                                                                }];
                                     }
                                 }
                             }];
        }

        //@TODO do similar to the cookies above and restrict to only our app
        if ([cachesToDelete containsObject:@"assets"]) {  // or diskcache
            [websiteDataTypes addObject:WKWebsiteDataTypeDiskCache];
        }

        // @TODO get a passed in date from client, which could be the BuildDate from the BuildInfo or Device plugins?
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            //NSLog(@"Cordova iOS webview cache cleared.");
        }];

      [self success];
    }];
}

- (void)success
{
    NSString *resultMsg = @"Cordova iOS wkwebview cache cleared.";
    NSLog(@"%@", resultMsg);

    // create a cordova result
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                messageAsString:[resultMsg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    // send cordova result
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)error:(NSString *)message
{
    NSString *resultMsg = [NSString stringWithFormat:@"Error while clearing wkwebview cache (%@).", message];
    NSLog(@"%@", resultMsg);

    // create cordova result
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                messageAsString:[resultMsg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    // send cordova result
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


//WKWebsiteDataTypeDiskCache,
//WKWebsiteDataTypeOfflineWebApplicationCache,
//WKWebsiteDataTypeMemoryCache,
//WKWebsiteDataTypeLocalStorage,
//WKWebsiteDataTypeCookies,
//WKWebsiteDataTypeSessionStorage,
//WKWebsiteDataTypeIndexedDBDatabases,
//WKWebsiteDataTypeWebSQLDatabases,
//WKWebsiteDataTypeFetchCache, //(iOS 11.3, *)
//WKWebsiteDataTypeServiceWorkerRegistrations, //(iOS 11.3, *)

@end
