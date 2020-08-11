//
//  KeywordInterceptor.m
//  ObjCExampleApp
//
//  Created by Brett Clifton on 8/11/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeywordInterceptor.h"
#import "ObjCExampleApp-Swift.h"
//#import <AASDK/AASDK.h>

@interface KeywordInterceptor ()

@end

@implementation KeywordInterceptor

- (NSString*)getInterceptSuggestions:(NSString*)inputText {
//    NSDictionary *results = [AASDK keywordInterceptFor: inputText];
//
//    if (results) {
//        NSLog(@"Keyword intercept suggestion available");
//        NSString *suggestionName = results[AASDK_KEY_KI_REPLACEMENT_TEXT];
//        NSLog(@"Suggestion item name: %@", suggestionName);
//        [AASDK keywordInterceptPresented];
//        return suggestionName;
//    } else { return nil; }
    
    return nil;
}

- (void)interceptWasSelected {
    //[AASDK keywordInterceptSelected];
}

@end
