//
//  LinksTableViewController.h
//  Tufts
//
//  Created by Amadou Crookes on 8/17/13.
//  Copyright (c) 2013 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinksTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSArray* links;
@property (nonatomic, strong) UIColor* backgroundColor;
@property (nonatomic) bool isLoading;

- (void)loadData;

@end
