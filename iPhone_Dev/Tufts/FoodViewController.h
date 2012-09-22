//
//  FoodViewController.h
//  Tufts
//
//  Created by Amadou Crookes on 5/21/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface FoodViewController : UIViewController

@property (nonatomic,strong) id food;
@property (weak, nonatomic) IBOutlet UILabel *servingSize;
@property (weak, nonatomic) IBOutlet UILabel *calories;
@property (weak, nonatomic) IBOutlet UILabel *fat;
@property (weak, nonatomic) IBOutlet UILabel *satFat;
@property (weak, nonatomic) IBOutlet UILabel *cholestoral;
@property (weak, nonatomic) IBOutlet UILabel *sodium;
@property (weak, nonatomic) IBOutlet UILabel *carbs;
@property (weak, nonatomic) IBOutlet UILabel *fiber;
@property (weak, nonatomic) IBOutlet UILabel *sugars;
@property (weak, nonatomic) IBOutlet UILabel *protein;
@property (weak, nonatomic) IBOutlet UITextView *ingredients;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *allergens;

- (void)loadData;


@end
