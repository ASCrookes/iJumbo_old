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
	[self.feedbackInputField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setFeedbackInputField:nil];
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
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:self.feedbackInputField.text forKey:@"feedback"];
    [request startSynchronous];
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    UIAlertView* thanksAlert = [[UIAlertView alloc] initWithTitle:@"Thanks!" message:@"We appreciate the feedback" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [thanksAlert show];
    [self dismissModalViewControllerAnimated:YES];
    // Use when fetching binary data
}

- (IBAction)cancelAction:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}



@end
