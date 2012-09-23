//
//  MyFoodViewController.m
//  Tufts
//
//  Created by Amadou Crookes on 9/22/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "MyFoodViewController.h"

@interface MyFoodViewController ()

@end

@implementation MyFoodViewController

@synthesize myFood = _myFood;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.myFood count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Food Channel Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [[@"[" stringByAppendingString:[self.myFood objectAtIndex:indexPath.row]] stringByAppendingString:@"]"];
    // Configure the cell...
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray* editableList = [NSMutableArray arrayWithArray:self.myFood];
    NSString* channel = [self.myFood objectAtIndex:indexPath.row];
    [editableList removeObjectAtIndex:indexPath.row];
    self.myFood = editableList;
    [PFPush unsubscribeFromChannelInBackground:channel];
    [self.tableView reloadData];
}

- (NSArray*)myFood
{
    if(!_myFood) {
        _myFood = [[PFPush getSubscribedChannels:nil] allObjects];
        NSMutableArray* foodChannels = [NSMutableArray arrayWithArray:_myFood];
        [foodChannels removeObject:@""];
        _myFood = foodChannels;
    }
    return _myFood;
}



@end


