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
	// Do any additional setup after loading the view.
    
}

- (void)loadData
{
    [self loadView];
    _servingSize.text = [_food objectForKey:@"serving_size"];
    _calories.text = [_food objectForKey:@"calories"];
    _fat.text = [_food objectForKey:@"fat_calories"];
    _satFat.text = [_food objectForKey:@"saturated_fat"];
    _cholestoral.text = [_food objectForKey:@"cholesterol"];
    _sodium.text = [_food objectForKey:@"sodium"];
    _carbs.text = [_food objectForKey:@"total_carbs"];
    _fiber.text = [_food objectForKey:@"fiber"];
    _sugars.text = [_food objectForKey:@"sugars"];
    _protein.text = [_food objectForKey:@"protein"];
    _ingredients.text = [_food objectForKey:@"ingredients"];
    _allergens.text = [_food objectForKey:@"allergens"];
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

@end
