#import "WkCacheClear.h"
#import <WebKit/WKWebsiteDataStore.h>


@implementation WkCacheClear
@synthesize command;

/*
Calls are async operations and SHOULD BE CALLED FROM THE MAIN THREAD (?)
*/

- (void)task:(CDVInvokedUrlCommand *)command
{
    NSLog(@"Cordova iOS WkCacheClear() called");

    @try {
        self.command = command;

        if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_9_0) {
            NSLog(@"iOS version is too old: %f", NSFoundationVersionNumber);
            @throw [[NSException alloc] initWithName:@"iOSVersionTooOld" reason:[NSString stringWithFormat:@"iOS version is too old: %f", NSFoundationVersionNumber] userInfo:nil];
        }

        NSArray* cachesToDelete;
        NSDictionary* options;

        if ([command.arguments count] == 1) {
            options = [command.arguments objectAtIndex:0];

            if ( [options isKindOfClass:[NSDictionary class]] ) {
                cachesToDelete = [options objectForKey:@"delete"];

                if ( ![options objectForKey:@"domain"]) {
                    /* domain is required. */
                    @throw [[NSException alloc] initWithName:@"BadParameters" reason:[NSString stringWithFormat:@"The option: domain is required"] userInfo:nil];
                }
            } else {
                @throw [[NSException alloc] initWithName:@"BadParameters" reason:[NSString stringWithFormat:@"The options object cannot be empty"] userInfo:nil];
            }
        } else {
            @throw [[NSException alloc] initWithName:@"BadParameters" reason:[NSString stringWithFormat:@"The options object is not present"] userInfo:nil];
        }

        NSLog(@"clear cache options = %@", cachesToDelete);

        /* These are the default types, which are always cleared */
        NSMutableSet *websiteDataTypes = [NSMutableSet setWithArray:@[WKWebsiteDataTypeMemoryCache,WKWebsiteDataTypeOfflineWebApplicationCache]];

        /* Delete the file cache? */
        if ([cachesToDelete containsObject:@"assets"]) {
            [websiteDataTypes addObject:WKWebsiteDataTypeDiskCache];
            NSLog(@"assets will be cleared");
        }

        /* Delete the cookies? */
        if ([cachesToDelete containsObject:@"cookies"]) {
            [websiteDataTypes addObject:WKWebsiteDataTypeCookies];
            NSLog(@"cookies will be cleared");
        }

        WKWebsiteDataStore *dataStore = [WKWebsiteDataStore defaultDataStore];
        [dataStore fetchDataRecordsOfTypes:websiteDataTypes
                         completionHandler:^(NSArray<WKWebsiteDataRecord *> * _Nonnull records) {
                             //NSLog(@"Record = %@", records);

                             for (WKWebsiteDataRecord *record  in records) {
                                 /* only delete records for the specified domain */
                                 if ( [record.displayName containsString:options[@"domain"]]) {
                                     [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                                               forDataRecords:@[record]
                                                                            completionHandler:^{}
                                     ];
                                 }
                             }
                         }
        ];

        [self success];

    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
        [self error:[NSString stringWithFormat:@"EXCEPTION: %@: %@", exception.name, exception.reason]];
    }
}


- (void)success
{
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    [self.commandDelegate sendPluginResult:result callbackId:self.command.callbackId];
}


- (void)error:(NSString *)message
{
    NSString *resultMsg = [NSString stringWithFormat:@"Error while clearing wkwebview cache (%@).", message];
    NSLog(@"%@", resultMsg);

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                messageAsString:[resultMsg stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet] ]];

    [self.commandDelegate sendPluginResult:result callbackId:self.command.callbackId];
}

@end
