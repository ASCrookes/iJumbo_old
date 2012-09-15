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

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        UIViewController* aboutTufts = [self.storyboard instantiateViewControllerWithIdentifier:@"About Tufts"];
        aboutTufts.view.backgroundColor = self.tableView.backgroundColor;
        UINavigationController* aboutTuftsNavcon = [self navconWithRootViewController:aboutTufts BackButtonTitle:@"Back"];
        [self presentModalViewController:aboutTuftsNavcon animated:YES];
    } else if(indexPath.section == 4) {
        FeedbackViewController* feedbackView = [self.storyboard instantiateViewControllerWithIdentifier:@"Feedback Input View"];
        feedbackView.view.backgroundColor = self.view.backgroundColor;
        [feedbackView.feedbackInputField becomeFirstResponder];
        feedbackView.title = @"Feedback";
        UINavigationController* navcon = [self navconWithRootViewController:feedbackView BackButtonTitle:@"Cancel"];
        [self presentModalViewController:navcon animated:YES];
    } else if(indexPath.section == 6) {
        SourcesViewController* sourceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Sources View Controller"];
        sourceVC.view.backgroundColor = self.tableView.backgroundColor;
        UINavigationController* navcon = [self navconWithRootViewController:sourceVC BackButtonTitle:@"Back"];
        [self presentModalViewController:navcon animated:YES];
    }
}

- (UINavigationController*)navconWithRootViewController:(UIViewController*)vc BackButtonTitle:(NSString*)backTitle
{
    UINavigationController* navcon = [[UINavigationController alloc] initWithRootViewController:vc];
    navcon.navigationBar.tintColor = [UIColor blackColor];
    navcon.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UIBarButtonItem* barButton = [[UIBarButtonItem alloc] initWithTitle:backTitle style:UIBarButtonItemStylePlain target:self action:@selector(dismissModalViewControllerAnimated:)];
    vc.navigationItem.leftBarButtonItem = barButton;
    navcon.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    return navcon;
}


@end
