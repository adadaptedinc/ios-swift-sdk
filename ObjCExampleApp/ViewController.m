//
//  ViewController.m
//  AAObjCExampleApp
//
//  Created by Brett Clifton on 8/10/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

#import "ViewController.h"
#import "ObjCExampleApp-Swift.h"
@import AASwiftSDK;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet AAAdAdaptedZoneView *adZone;
@property (weak, nonatomic) IBOutlet ObjCSearchTextField *searchTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaultItems = [[NSMutableArray alloc]initWithObjects:@"Milk",@"Bread",@"Coffee",@"Eggs",@"Cheese", nil];
    listData = [[NSMutableArray alloc]initWithObjects:@"Milk",@"Bread", nil];
    listTableView.dataSource = self;
    listTableView.delegate = self;
    _searchTextField.delegate = self;
    
    [_adZone setZoneOwner:self];
    [AASDK registerContentListenersFor:self];
    
    _searchTextField.minCharactersNumberToStartFiltering = 3;
    [_searchTextField filterStrings: defaultItems];
    
}

- (void)aaContentNotification:(NSNotification*)notification {
    NSLog(@"In-app content available");
    AAAdContent *adContent = [[notification userInfo] objectForKey:AASDK.AASDK_KEY_AD_CONTENT];

    for (AADetailedListItem *item in adContent.detailedListItems) {
        NSLog(@"AADetailedListItem: %@", item.productTitle);
        [self insertItemToList:item.productTitle];
    }

    // Acknowledge the items were added to the list
    [adContent acknowledge];
}

- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)zoneViewDidLoadZone:(AAZoneView *)view {
    NSLog(@"Zone LOADED");
}

- (void)zoneViewDidFailToLoadZone:(AAZoneView *)view {
    NSLog(@"Zone FAILED TO LOAD");
}

- (void)aaPayloadNotification:(NSNotification*)notification {
    NSLog(@"Out-of-app content available");
    NSArray *adPayload = [notification.userInfo objectForKey:AASDK.AASDK_KEY_CONTENT_PAYLOADS];

    for (AAContentPayload* payload in adPayload) {
        for (AADetailedListItem *item in payload.detailedListItems) {
            NSLog(@"AADetailedListItem: %@", item.productTitle);
            [self insertItemToList:item.productTitle];
        }

        [payload acknowledge];
    }
}

//Non AASDK calls

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
     static NSString *cellId = @"SimpleTableId";
       
       UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
       if (cell == nil) {
           cell = [[UITableViewCell alloc]initWithStyle:
                   UITableViewCellStyleDefault reuseIdentifier:cellId];
       }
    NSString *stringForCell;
    stringForCell= [listData objectAtIndex:indexPath.row];
    [cell.textLabel setText:stringForCell];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [listData count];
}

- (IBAction)addToList:(id)sender {
    if (_searchTextField.text.length != 0) {
        [self insertItemToList:_searchTextField.text];
        _searchTextField.text = @"";
    }
}

- (void)insertItemToList:(NSString*)itemName {
    [listData addObject:itemName];
    [listTableView reloadData];
}

- (BOOL)textFieldShouldReturn:(ObjCSearchTextField *)textField {
    [self addToList:_searchTextField];
    return YES;
}

@end
