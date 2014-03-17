//
//  StandardUtils.h
//  Tufts
//
//  Created by Amadou Crookes on 3/5/14.
//  Copyright (c) 2014 Amadou Crookes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StandardUtils : NSObject

+ (UIColor*)blueColor;
+ (UIViewController*)viewControllerFromStoryboardWithIdentifier:(NSString*)identifier;
+ (BOOL)isNull:(id)object;

@end
