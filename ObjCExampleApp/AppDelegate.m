//
//  AppDelegate.m
//  ObjCExampleApp
//
//  Created by Brett Clifton on 8/10/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

#import "AppDelegate.h"
@import AASwiftSDK;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary *options = @{
        AASDK.OPTION_TEST_MODE:@YES,
        AASDK.OPTION_KEYWORD_INTERCEPT:@YES
       };

    [AASDK startSessionWithAppID:@"NWY0NTZIODZHNWY0" registerListenersFor:self options:options];
    
    return YES;
}

- (void)aaSDKInitComplete:(nonnull NSNotification *)notification {
    NSLog(@"%@", notification);

    // Get an array of zone IDs for application
       NSArray *ids = [AASDK availableZoneIDs];

       // Check for valid zone IDs
       if (!ids || !ids.count) {
           NSLog(@"No ad zones available");
           // Don't try to load any ads
       }
       else {
           // Check valid zone IDs for available ads
           for (NSString *zoneId in ids) {
               if ([AASDK zoneAvailable: zoneId]) {
                   NSLog(@"Zone #%@ has ads available to load", zoneId);
                   // Try to load ads...
               }
           }
       }
}

- (void)aaSDKError:(nonnull NSNotification *)error {
    NSLog(@"%@", error);
}

- (void)aaSDKKeywordInterceptInitComplete:(NSNotification *)notification {
    NSLog(@"%@", notification);
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
}

@end
