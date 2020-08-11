//
//  KeywordInterceptor.h
//  AASwiftSDK
//
//  Created by Brett Clifton on 8/11/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeywordInterceptor: NSObject
    
- (NSString*)getInterceptSuggestions:(NSString*)inputText;
- (void)interceptWasSelected;

@end
