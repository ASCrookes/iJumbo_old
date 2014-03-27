//
//  InfoViewController.m
//  Tufts
//
//  Created by Amadou Crookes on 8/3/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        UIViewController* aboutTufts = [StandardUtils viewControllerFromStoryboardWithIdentifier:@"About Tufts"];
        aboutTufts.view.backgroundColor = self.tableView.backgroundColor;
        [self.navigationController pushViewController:aboutTufts animated:YES];
    } else if(indexPath.section == 4) {
        FeedbackViewController* feedbackView = (FeedbackViewController*)[StandardUtils viewControllerFromStoryboardWithIdentifier:@"Feedback Input View"];
        feedbackView.view.backgroundColor = self.view.backgroundColor;
        feedbackView.title = @"Feedback";
        [self.navigationController pushViewController:feedbackView animated:YES];
    } else if(indexPath.section == 6) {
        SourcesViewController* sourceVC = (SourcesViewController*)[StandardUtils viewControllerFromStoryboardWithIdentifier:@"Sources View Controller"];
        sourceVC.view.backgroundColor = self.tableView.backgroundColor;
        [self.navigationController pushViewController:sourceVC animated:YES];// presentModalViewController:navcon animated:YES];
    }
}

- (UINavigationController*)navconWithRootViewController:(UIViewController*)vc BackButtonTitle:(NSString*)backTitle
{
    UINavigationController* navcon = [[UINavigationController alloc] initWithRootViewController:vc];
    navcon.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UIBarButtonItem* barButton = [[UIBarButtonItem alloc] initWithTitle:backTitle style:UIBarButtonItemStylePlain target:self action:@selector(dismissModalViewControllerAnimated:)];
    vc.navigationItem.leftBarButtonItem = barButton;
    navcon.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [navcon.navigationBar setBarTintColor:[StandardUtils blueColor]];
    
    return navcon;
}


@end
