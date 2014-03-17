//
//  NetworkManager.m
//  Tufts
//
//  Created by Amadou Crookes on 3/17/14.
//  Copyright (c) 2014 Amadou Crookes. All rights reserved.
//

#import "NetworkManager.h"

@interface NetworkManager ()
@property (nonatomic, strong) NSCache* imageCache;
@property (nonatomic, strong) NSMutableSet* urlsBeingFetched;  // urls currently being downloaded
@end

@implementation NetworkManager

@synthesize imageCache = _imageCache;
@synthesize urlsBeingFetched = _urlsBeingFetched;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.imageCache = nil;
        self.urlsBeingFetched = nil;
    }
    return self;
}

+ (NetworkManager*)sharedManager {
    static NetworkManager* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[NetworkManager alloc] init];
    });
    return sharedManager;
}

+ (UIImage*)imageFromUrl:(NSString *)url {
    return [[NetworkManager sharedManager] imageFromUrl:url];
}

- (UIImage*)imageFromUrl:(NSString*)url {
    NSAssert(url, @"Trying to get an image without a url");
    UIImage* cachedImage = [self.imageCache objectForKey:url];
    if (cachedImage == nil && ![self.urlsBeingFetched member:url]) {
        [self.urlsBeingFetched addObject:url];
        dispatch_queue_t queue = dispatch_queue_create("NetworkManager.imageFromUrl", nil);
        dispatch_async(queue, ^{
            NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            if (imageData && imageData.length > 0) {
                UIImage* image = [UIImage imageWithData:imageData];
                [self.imageCache setObject:image forKey:url];
            } else {
                [self.imageCache setObject:[NSNull null] forKey:url];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadedImageNotification object:nil];
            [self.urlsBeingFetched removeObject:url];
        });
        return nil;
    }
    return cachedImage;
}

- (NSCache*)imageCache {
    if (!_imageCache) {
        _imageCache = [[NSCache alloc] init];
    }
    return _imageCache;
}

- (NSMutableSet*)urlsBeingFetched {
    if (!_urlsBeingFetched) {
        _urlsBeingFetched = [[NSMutableSet alloc] init];
    }
    return _urlsBeingFetched;
}

@end
