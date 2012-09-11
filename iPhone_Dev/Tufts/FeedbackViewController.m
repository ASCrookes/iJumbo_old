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
    [TestFlight submitFeedback:self.feedbackInputField.text];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Thanks!" message:@"We appreciate the feedback" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)cancelAction:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}



@end
