//
//  StandardUtils.h
//  Tufts
//
//  Created by Amadou Crookes on 3/5/14.
//  Copyright (c) 2014 Amadou Crookes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StandardUtils : NSObject

// iJumbo blue.
+ (UIColor*)blueColor;
// Create a view controller from the appropriate storyboard.
+ (UIViewController*)viewControllerFromStoryboardWithIdentifier:(NSString*)identifier;
// YES if nil or NSNull
+ (BOOL)isNull:(id)object;
// Standard background color used by the view controllers.
+ (UIColor*)backgroundColor;

@end
