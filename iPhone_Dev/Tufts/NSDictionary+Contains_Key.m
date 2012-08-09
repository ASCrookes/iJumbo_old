//
//  NSDictionary+Contains_Key.m
//  Tufts
//
//  Created by Amadou Crookes on 6/24/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "NSDictionary+Contains_Key.h"

@implementation NSDictionary (Contains_Key)

- (BOOL)containsKey:(NSString*)key
{
    BOOL contained = NO;
    NSArray* allKeys = [self allKeys];
    for(int i = 0; i < [allKeys count] && !contained; i++)
    {
        contained = [key isEqualToString:[allKeys objectAtIndex:i]];
    }
    
    return  contained;
}



@end
