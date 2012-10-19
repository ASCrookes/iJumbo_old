//
//  FeedbackViewController.m
//  Tufts
//
//  Created by Amadou Crookes on 8/3/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

@synthesize feedbackInputField;


- (void)viewDidLoad
{    
    UIBarButtonItem* submit = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(sendAction:)];
    self.navigationItem.rightBarButtonItem = submit;
	[self.emailField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setFeedbackInputField:nil];
    [self setEmailField:nil];
    [self setEmailField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)sendAction:(id)sender 
{
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://ijumboapp.com/api/feedback"]];
    [request setRequestMethod:@"POST"];
    NSString* feedback = [[self.feedbackInputField.text stringByAppendingString:@"\n\n-------\n\n"]
                                                        stringByAppendingString:self.emailField.text];
    [request setPostValue:feedback forKey:@"feedback"];
    self.emailField.userInteractionEnabled = NO;
    [self.emailField resignFirstResponder];
    self.feedbackInputField.text = @"Sending Feedback...";
    self.feedbackInputField.userInteractionEnabled = NO;
    [self.feedbackInputField resignFirstResponder];
    // instead of getting rid of the button make it an activity indicator
    UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [activityView sizeToFit];
    [activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [activityView startAnimating];
    UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    self.navigationItem.rightBarButtonItem = loadingView;
    self.navigationItem.leftBarButtonItem  = nil;
    dispatch_queue_t queue = dispatch_queue_create("com.feedback.ijumbo", nil);
    dispatch_async(queue, ^{
        [request startSynchronous];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* thanksAlert = [[UIAlertView alloc] initWithTitle:@"Thanks!" message:@"We appreciate the feedback" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [thanksAlert show];
            [self dismissModalViewControllerAnimated:YES];
        });
    });
    dispatch_release(queue);
}


- (IBAction)cancelAction:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}


@end
