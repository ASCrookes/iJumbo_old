//
//  LinksTableViewController.m
//  Tufts
//
//  Created by Amadou Crookes on 8/17/13.
//  Copyright (c) 2013 Amadou Crookes. All rights reserved.
//

#import "LinksTableViewController.h"
#import "WebViewController.h"

@interface LinksTableViewController ()

@end

@implementation LinksTableViewController

@synthesize tableView = _tableView;
@synthesize links = _links;
@synthesize isLoading = _isLoading;
@synthesize backgroundColor = _backgroundColor;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];
	// Do any additional setup after loading the view.
    if (!self.isLoading) {
        [self.tableView reloadData];
    }
    [self loadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.isLoading) {
        [self loadData];
    }
}

- (void)setupTableView {
    self.view.backgroundColor = self.backgroundColor;
    self.tableView.backgroundColor = self.backgroundColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData {
    if (self.isLoading)
        return;
    self.isLoading = YES;
    [self showActivityIndicator];
    dispatch_queue_t queue = dispatch_queue_create("Links.Table.Load", nil);
    dispatch_async(queue, ^{
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://ijumboapp.com/api/json/links"]];
        NSError* error;
        self.links = [NSJSONSerialization JSONObjectWithData:data
                                                     options:0
                                                       error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = nil;
            [self.tableView reloadData];
        });
    });
}

//*********************************************************
//*********************************************************
#pragma mark - Table datasource & delegate
//*********************************************************
//*********************************************************

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.links count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"LinksCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary* info = self.links[indexPath.section];
    cell.textLabel.text = info[@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WebViewController* wvc = [[UIStoryboard storyboardWithName:@"MainStoryboard1" bundle:nil] instantiateViewControllerWithIdentifier:@"Web View"];
    NSDictionary* info = self.links[indexPath.section];
    [wvc setWebViewWithURL:info[@"link"] delegate:self];
    wvc.title = info[@"name"];
    [self.navigationController pushViewController:wvc animated:YES];
}

- (void)showActivityIndicator {
    UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [activityView sizeToFit];
    [activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [activityView startAnimating];
    UIBarButtonItem* bar_button = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    self.navigationItem.rightBarButtonItem = bar_button;
}

@end
