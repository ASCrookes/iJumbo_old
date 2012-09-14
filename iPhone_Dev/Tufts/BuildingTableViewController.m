//
//  BuildingTableViewController.m
//  Tufts
//
//  Created by Amadou Crookes on 5/9/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "BuildingTableViewController.h"



@interface BuildingTableViewController ()

@end


@implementation BuildingTableViewController

@synthesize buildings = _buildings;
@synthesize mapSelect = _mapSelect;
@synthesize searchBar = _searchBar;
@synthesize delegate = _delegate;


//*********************************************************
//*********************************************************
#pragma mark - Standard Stuff
//*********************************************************
//*********************************************************

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
    self.title = @"Places";
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//*********************************************************
//*********************************************************
#pragma mark - JSON loading
//*********************************************************
//*********************************************************

- (void)loadData
{
    dispatch_queue_t queue = dispatch_queue_create("Building Table Load", NULL);
    dispatch_async(queue, ^{
        NSURL *url = [NSURL URLWithString:@"http://www.eecs.tufts.edu/~acrook01/files/buildings.json"];
        
        // Set up a concurrent queue
        NSData *data = [NSData dataWithContentsOfURL:url];
        if(data == nil) {
            return;
        }
        NSError* error;
        _buildings = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadView];
        });
    });
    dispatch_release(queue);
}


//*********************************************************
//*********************************************************
#pragma mark - Search
//*********************************************************
//*********************************************************

- (NSArray*)searchForText:(NSString*)text
{
    NSMutableArray* results = [[NSMutableArray alloc] init];
    char startChar = [text characterAtIndex:0];
    bool sectionFound = NO;
    int index = 0;
    if(startChar == '1') {
        //DO SOME SHIT
        sectionFound = YES;
    }
    
    for(index = 0; index < [_buildings count] && !sectionFound; index++)
    {
        char sectionChar = [[[[_buildings objectAtIndex:index] objectAtIndex:0] objectForKey:@"building_name"] characterAtIndex:0];
        if(sectionChar == startChar) {
            sectionFound = YES;
        }
    }
    
    for(NSDictionary* building in [_buildings objectAtIndex:index])
    {
        NSString* title = [[building objectForKey:@"building_name"] lowercaseString];
        NSString* searchFor = [text lowercaseString];
        if([title hasPrefix:searchFor]) {
            [results addObject:building];
        }
    }
    
    return results;
    
}

//*********************************************************
//*********************************************************
#pragma mark - UISearchBar Delegate
//*********************************************************
//*********************************************************

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSArray* results = [self searchForText:searchBar.text];
    _buildings = [NSArray arrayWithObject:results];
}



//*********************************************************
//*********************************************************
#pragma mark - Table View Delegate/Data Source
//*********************************************************
//*********************************************************

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_buildings count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[_buildings objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Building Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    cell.textLabel.text = [(NSDictionary*)[[_buildings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"building_name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_mapSelect) {
        [self.delegate selectedBuilding:[[_buildings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    } else {
        BuildingViewController* bvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Building View"];
        bvc.allowsMap = YES;
        [bvc setBuilding:[[_buildings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:bvc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    BuildingViewController* bvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Building View"];
    bvc.allowsMap = YES;
    [bvc setBuilding:[[_buildings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:bvc animated:YES];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* sectionTitle = [[[[_buildings objectAtIndex:section] objectAtIndex:0] objectForKey:@"building_name"] substringToIndex:1];
    if([sectionTitle isEqualToString:@"1"]) {
        sectionTitle = @"123";
    }
    return sectionTitle;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 320, 45)];
    label.backgroundColor = self.tableView.backgroundColor;
    NSString* sectionTitle = [[[[_buildings objectAtIndex:section] objectAtIndex:0] objectForKey:@"building_name"] substringToIndex:1];
    if([sectionTitle isEqualToString:@"1"]) {
        sectionTitle = @"123";
    }
    label.text = sectionTitle;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.numberOfLines = 2;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumFontSize = 14;
    UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    [header addSubview:label];
    
    return header;
}

@end
