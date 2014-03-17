//
//  NetworkManager.h
//  Tufts
//
//  Created by Amadou Crookes on 3/17/14.
//  Copyright (c) 2014 Amadou Crookes. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const kDownloadedImageNotification = @"DownloadedImage";

@interface NetworkManager : NSObject

+ (UIImage*)imageFromUrl:(NSString*)url;

@end
