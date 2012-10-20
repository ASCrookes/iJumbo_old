//
//  FoodViewController.m
//  Tufts
//
//  Created by Amadou Crookes on 5/21/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "FoodViewController.h"

@interface FoodViewController ()

@end

@implementation FoodViewController

@synthesize food = _food;
@synthesize servingSize = _servingSize;
@synthesize calories = _calories;
@synthesize fat = _fat;
@synthesize satFat = _satFat;
@synthesize cholestoral = _cholestoral;
@synthesize sodium = _sodium;
@synthesize carbs = _carbs;
@synthesize fiber = _fiber;
@synthesize sugars = _sugars;
@synthesize protein = _protein;
@synthesize ingredients = _ingredients;
@synthesize scrollView = _scrollView;
@synthesize allergens = _allergens;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
    self.scrollView.contentSize = CGSizeMake(320, 675);
    UIBarButtonItem* foodAlert = [[UIBarButtonItem alloc] initWithTitle:@"Alert" style:UIBarButtonItemStylePlain target:self action:@selector(subscribeToFood)];
	self.navigationItem.rightBarButtonItem = foodAlert;
    
}

- (void)loadData
{
    [self loadView];
    [_servingSize setText:[_food objectForKey:@"serving_size"]];
    [_calories setText:[_food objectForKey:@"calories"]];
    [_fat setText:[_food objectForKey:@"fat_calories"]];
    [_satFat setText:[_food objectForKey:@"saturated_fat"]];
    [_cholestoral setText:[_food objectForKey:@"cholesterol"]];
    [_sodium setText:[_food objectForKey:@"sodium"]];
    [_carbs setText:[_food objectForKey:@"total_carbs"]];
    [_fiber setText:[_food objectForKey:@"fiber"]];
    [_sugars setText:[_food objectForKey:@"sugars"]];
    [_protein setText:[_food objectForKey:@"protein"]];
    [_ingredients setText:[_food objectForKey:@"ingredients"]];
    [_allergens setText:[_food objectForKey:@"allergens"]];
}


- (void)viewDidUnload
{
    [self setServingSize:nil];
    [self setCalories:nil];
    [self setFat:nil];
    [self setSatFat:nil];
    [self setCholestoral:nil];
    [self setSodium:nil];
    [self setCarbs:nil];
    [self setFiber:nil];
    [self setSugars:nil];
    [self setProtein:nil];
    [self setIngredients:nil];
    [self setScrollView:nil];
    [self setAllergens:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
                                  
- (void)subscribeToFood
{
    NSString* channelName = [[self.food objectForKey:@"FoodName"] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    channelName = [channelName stringByReplacingOccurrencesOfString:@"&" withString:@"-+and+-"];
    [PFPush subscribeToChannelInBackground:channelName block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Successfully subscribed to the channel.");
        } else {
            NSLog(@"Failed to subscribe to the channel.");
        }
    }];
}
                                

@end
