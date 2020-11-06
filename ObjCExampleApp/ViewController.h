//
//  ViewController.h
//  ObjCExampleApp
//
//  Created by Brett Clifton on 8/10/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AASwiftSDK/AASwiftSDK-Swift.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchTextFieldDelegate, AAZoneViewOwner, AASDKContentDelegate> {
    IBOutlet UITableView *listTableView;
    NSMutableArray *listData;
    NSMutableArray *defaultItems;
}
@end

