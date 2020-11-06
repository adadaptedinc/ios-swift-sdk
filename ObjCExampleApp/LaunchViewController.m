//
//  LaunchViewController.m
//  ObjCExampleApp
//
//  Created by Brett Clifton on 8/11/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

#import "LaunchViewController.h"
#import "ObjCExampleApp-Swift.h"
#import <AASwiftSDK/AASwiftSDK-Swift.h>

@interface LaunchViewController ()

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)testListManagerReports:(id)sender {
    // Item added to list
    [AASDK reportItem: @"added_product_name" addedToList: @"objc_list"];
    [AASDK reportItems: @[@"first_product_name",@"second_product_name",@"etc."] addedToList: @"objc_list"];

     //Item crossed off list
    [AASDK reportItem: @"crossed_off_product_name" crossedOffList: @"objc_list"];
    [AASDK reportItems: @[@"first_crossed_off_product_name",@"second_crossed_off_product_name",@"etc."] crossedOffList: @"objc_list"];

     //Item removed from list
    [AASDK reportItem: @"deleted_product_name" deletedFromList: @"objc_list"];
    [AASDK reportItems: @[@"first_deleted_product_name",@"second_deleted_product_name",@"etc."] deletedFromList: @"objc_list"];
    
    [Toast showToastWithMessage:@"Test Reports Sent" font:[UIFont fontWithName:@"Sansation-Light" size:13.0] view:self.view];
}

@end

