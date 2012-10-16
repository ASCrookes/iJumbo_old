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
@synthesize allFood = _allFood;
@synthesize dataSource = _dataSource;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UISegmentedControl* segControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Alerts", @"All Food", nil]];
    segControl.selectedSegmentIndex = 0;
    [segControl addTarget:self action:@selector(segmentChange) forControlEvents:UIControlEventValueChanged];
    [segControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    self.navigationItem.titleView = segControl;
    self.editButtonItem.target = self;
    self.editButtonItem.action = @selector(toggleTableEditMode);
    [self segmentChange];

}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadData];
    [self segmentChange];
}

- (void)toggleTableEditMode
{
    if(self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
        self.editButtonItem.title = @"Edit";
    } else {
        [self.tableView setEditing:!self.tableView.editing animated:YES];
        self.editButtonItem.title = @"Done";
    }
}

- (void)segmentChange
{
    int segmentIndex = ((UISegmentedControl*)self.navigationItem.titleView).selectedSegmentIndex;
    if(segmentIndex == 0) {
        self.dataSource = self.myFood;
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    } else {
        self.dataSource = self.allFood;
        self.myFood = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Food Name Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString* cellText = [self.dataSource objectAtIndex:indexPath.row];
    if(((UISegmentedControl*)self.navigationItem.titleView).selectedSegmentIndex == 0) {
        cellText = [cellText stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    }
    cell.textLabel.text = cellText;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int segmentIndex = ((UISegmentedControl*)self.navigationItem.titleView).selectedSegmentIndex;
    if(segmentIndex == 0){
        return;
    }
    NSString* channel = [[self.dataSource objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    channel = [channel stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
    [PFPush subscribeToChannelInBackground:channel];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [PFPush unsubscribeFromChannelInBackground:[self.myFood objectAtIndex:indexPath.row]];
        NSMutableArray* editableList = [NSMutableArray arrayWithArray:self.myFood];
        [editableList removeObjectAtIndex:indexPath.row];
        self.myFood = editableList;
        self.dataSource = self.myFood;
        [self.tableView reloadData];
    }
}


- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)loadData
{
    NSError* error;
    NSData* jsonData = [MyFoodViewController allFoodStoredData];
    if(jsonData) {
        NSLog(@"LOADED ALL THE FOOD DATA!");
        self.allFood = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    }
    dispatch_queue_t queue = dispatch_queue_create("all food queue", nil);
    dispatch_async(queue, ^{
        NSURL* allFoodURL = [NSURL URLWithString:@"http://ijumboapp.com/api/allFood"];
        NSData* data = [NSData dataWithContentsOfURL:allFoodURL];
        NSError* error;
        self.allFood = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        [data writeToURL:[MyFoodViewController storedFoodURL] atomically:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    dispatch_release(queue);
}

+ (NSData*)allFoodStoredData
{
    return [NSData dataWithContentsOfURL:[MyFoodViewController storedFoodURL]];
}
         
+ (NSURL*)storedFoodURL
{
    NSURL* mainURL = [[NSBundle mainBundle] bundleURL];
    NSURL* localURL = [NSURL URLWithString:@"allFood.json" relativeToURL:mainURL];
    return localURL;
}


- (NSArray*)myFood
{
    if(!_myFood) {
        return [NSArray array]; // DELME -> only needed when testing on simulator
        NSSet* foodSet = [PFPush getSubscribedChannels:nil];
        NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        _myFood = [foodSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        NSMutableArray* foodChannels = [NSMutableArray arrayWithArray:_myFood];
        [foodChannels removeObject:@""];
        _myFood = foodChannels;
    }
    return _myFood;
}

- (NSArray*)allFood
{
    if(!_allFood) {
        _allFood = [NSArray array];
    }
    return _allFood;
}


@end


