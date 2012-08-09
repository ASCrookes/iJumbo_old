//
//  BuildingViewController.h
//  Tufts
//
//  Created by Amadou Crookes on 5/10/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ViewController.h"

@interface BuildingViewController : UIViewController

@property (nonatomic,strong) id building;
@property (weak, nonatomic) IBOutlet UILabel *monday_hours;
@property (weak, nonatomic) IBOutlet UILabel *tuesday_hours;
@property (weak, nonatomic) IBOutlet UILabel *wednesday_hours;
@property (weak, nonatomic) IBOutlet UILabel *thursday_hours;
@property (weak, nonatomic) IBOutlet UILabel *friday_hours;
@property (weak, nonatomic) IBOutlet UILabel *saturday_hours;
@property (weak, nonatomic) IBOutlet UILabel *sunday_hours;
@property (weak, nonatomic) IBOutlet UILabel *building_name;
@property (weak, nonatomic) IBOutlet UITextView *phone_number;
@property (weak, nonatomic) IBOutlet UITextView *website;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *hours;
@property (nonatomic) BOOL allowsMap;

@property (weak, nonatomic) IBOutlet UILabel *monday_label;
@property (weak, nonatomic) IBOutlet UILabel *tuesday_label;
@property (weak, nonatomic) IBOutlet UILabel *wedbesday_label;
@property (weak, nonatomic) IBOutlet UILabel *thursday_label;
@property (weak, nonatomic) IBOutlet UILabel *friday_label;
@property (weak, nonatomic) IBOutlet UILabel *saturday_label;
@property (weak, nonatomic) IBOutlet UILabel *sunday_label;


@end
