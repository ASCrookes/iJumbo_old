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
    // setup the view based on the UI so far
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
        [self.tableView setEditing:YES animated:YES];
        self.editButtonItem.title = @"Done";
    }
}

- (void)segmentChange
{
    if(self.tableView.editing) {
        [self toggleTableEditMode];
    }
    self.editButtonItem.title = @"Edit";
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
    int segmentIndex = ((UISegmentedControl*)self.navigationItem.titleView).selectedSegmentIndex;
    if(segmentIndex == 0) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int segmentIndex = ((UISegmentedControl*)self.navigationItem.titleView).selectedSegmentIndex;
    if(section == 0 && segmentIndex != 0) {
        return 1;
    }
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"My Food Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    int segmentIndex = ((UISegmentedControl*)self.navigationItem.titleView).selectedSegmentIndex;
    if(indexPath.section == 0 && segmentIndex != 0) {
        cell.textLabel.text = @"Click a cell to subscribe to it";
        return cell;
    }
    NSString* cellText = [self.dataSource objectAtIndex:indexPath.row];
    // if the section is my food change the channel names to readable food
    if(((UISegmentedControl*)self.navigationItem.titleView).selectedSegmentIndex == 0) {
        cellText = [cellText substringFromIndex:4];
        cellText = [cellText stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        cellText = [cellText stringByReplacingOccurrencesOfString:@"--and--" withString:@"&"];
    }
    cell.textLabel.text = cellText;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int segmentIndex = ((UISegmentedControl*)self.navigationItem.titleView).selectedSegmentIndex;
    if(segmentIndex == 0 || indexPath.section == 0){
        return;
    }
    [MyFoodViewController subscribeToFood:[self.dataSource objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [PFPush unsubscribeFromChannelInBackground:[self.dataSource objectAtIndex:indexPath.row]];
        NSMutableArray* editableList = [NSMutableArray arrayWithArray:self.myFood];
        [editableList removeObjectAtIndex:indexPath.row];
        self.myFood = editableList;
        self.dataSource = self.myFood;
        [self.tableView reloadData];
    }
}


- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)loadData
{
    NSError* error;
    NSData* jsonData = [MyFoodViewController allFoodStoredData];
    // if there was data saved onto disk reload it and show that. then load the data from the server and write it
    if(jsonData) {
        self.allFood = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
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

// single point of truth for subscribing to a food

+ (void)subscribeToFood:(NSString*)foodName
{
    NSString* channel = [foodName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    channel = [channel stringByReplacingOccurrencesOfString:@"&" withString:@"--and--"];
    // channels must start with a letter -> append my initials
    channel = [@"ASC_" stringByAppendingString:channel];
    NSLog(@"CHANNEL: %@", channel);
    [PFPush subscribeToChannelInBackground:channel];
}


// setters and getters


- (NSArray*)myFood
{
    if(!_myFood) {
        NSSet* foodSet = [PFPush getSubscribedChannels:nil];
        NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        _myFood = [foodSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        NSMutableArray* foodChannels = [NSMutableArray arrayWithArray:_myFood];
        [foodChannels removeObject:@""];
        for(int i = 0; i < [foodChannels count]; i++) {
            NSString* foodName = [foodChannels objectAtIndex:i];
            foodName = [foodName substringFromIndex:4];
            foodName = [foodName stringByReplacingOccurrencesOfString:@"--and--" withString:@"&"];
            foodName = [foodName stringByReplacingOccurrencesOfString:@"_" withString:@" "];
            
        }
        _myFood = foodChannels;
        if(!_myFood) {
            _myFood = [NSArray array];
        }
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


