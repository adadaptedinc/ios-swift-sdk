//
//  AppDelegate.h
//  ObjCExampleApp
//
//  Created by Brett Clifton on 8/10/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AASwiftSDK/AASwiftSDK-Swift.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, AASDKObserver>
@property (strong, nonatomic) UIWindow *window;

@end

