//
//  FeedbackViewController.h
//  Tufts
//
//  Created by Amadou Crookes on 8/3/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"

@interface FeedbackViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *feedbackInputField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;


@end
