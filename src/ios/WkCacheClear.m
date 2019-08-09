#import "WkCacheClear.h"
#import <WebKit/WKWebsiteDataStore.h>

@implementation WkCacheClear
@synthesize command;


- (void)task:(CDVInvokedUrlCommand *)command
{
    NSLog(@"Cordova iOS WkCacheClear() called");

    @try {
        self.command = command;

        // if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_9_0) {
        if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_9_0) {
            NSLog(@"iOS version is too old: %f", NSFoundationVersionNumber);
            @throw [[NSException alloc] initWithName:@"iOSVersionTooOld" reason:[NSString stringWithFormat:@"iOS version is too old: %f", NSFoundationVersionNumber] userInfo:nil];
        }
        /*else {

        }*/

        NSArray* cachesToDelete;
        NSArray* arguments = command.arguments;
        NSDictionary* options = [arguments objectAtIndex:0];

        if ( ![options isKindOfClass:[NSNull class]] ) {
            cachesToDelete = [options objectForKey:@"delete"];
        }

        //NSLog(@"delete options = %@", cachesToDelete);
        NSMutableSet *websiteDataTypes = [NSMutableSet setWithArray:@[WKWebsiteDataTypeMemoryCache,WKWebsiteDataTypeOfflineWebApplicationCache]];

        if ([cachesToDelete containsObject:@"cookies"]) {
            NSLog(@"cookies will be cleared");

            WKWebsiteDataStore *dataStore = [WKWebsiteDataStore defaultDataStore];
            [dataStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                             completionHandler:^(NSArray<WKWebsiteDataRecord *> * _Nonnull records) {
                                 for (WKWebsiteDataRecord *record  in records) {
                                    // only delete OUR cookies!!
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

        if ([cachesToDelete containsObject:@"assets"]) {
            [websiteDataTypes addObject:WKWebsiteDataTypeDiskCache];
            NSLog(@"assets will be cleared");
        }

        // @TODO get a passed in date from client, which could be the BuildDate from the BuildInfo or Device plugins?
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{}];

        [self success];

    }@catch (NSException *exception) {
        NSLog(@"%@", exception);
        [self error:[NSString stringWithFormat:@"EXCEPTION: %@", exception.reason]];
    }
}


- (void)success
{
    NSString *resultMsg = @"Cordova iOS wkwebview cache cleared.";
    NSLog(@"%@", resultMsg);

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                messageAsString:[resultMsg stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet] ]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


- (void)error:(NSString *)message
{
    NSString *resultMsg = [NSString stringWithFormat:@"Error while clearing wkwebview cache (%@).", message];
    NSLog(@"%@", resultMsg);

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                messageAsString:[resultMsg stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet] ]];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end


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
