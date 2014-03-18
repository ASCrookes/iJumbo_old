//
//  StandardUtils.m
//  Tufts
//
//  Created by Amadou Crookes on 3/5/14.
//  Copyright (c) 2014 Amadou Crookes. All rights reserved.
//

#import "StandardUtils.h"

@implementation StandardUtils

+ (UIColor*)blueColor {
    return [UIColor colorWithRed:72.0/255 green:145.0/255 blue:206.0/255 alpha:1];
}

+ (UIViewController*)viewControllerFromStoryboardWithIdentifier:(NSString*)identifier {
    NSString* storyboardName = [[NSUserDefaults standardUserDefaults] objectForKey:@"storyboard"];
    UIViewController* vc = [[UIStoryboard storyboardWithName:storyboardName bundle:nil] instantiateViewControllerWithIdentifier:identifier];
    return vc;
}

+ (BOOL)isNull:(id)object {
    return (object == nil || [object class] == [NSNull class]);
}

+ (UIColor*)backgroundColor {
    return [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
}

@end
