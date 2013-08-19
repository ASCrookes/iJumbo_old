//
//  AboutTuftsViewController.m
//  Tufts
//
//  Created by Amadou Crookes on 8/3/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "AboutTuftsViewController.h"

@interface AboutTuftsViewController ()

@end

@implementation AboutTuftsViewController
@synthesize foundingField;
@synthesize visionStatementField;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewDidUnload
{
    [self setFoundingField:nil];
    [self setVisionStatementField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

@end
