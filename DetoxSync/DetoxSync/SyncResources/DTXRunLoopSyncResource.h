//
//  DTXRunLoopSyncResource.h
//  DetoxSync
//
//  Created by Leo Natan (Wix) on 8/6/19.
//  Copyright © 2019 wix. All rights reserved.
//

#import "DTXSyncResource.h"

NS_ASSUME_NONNULL_BEGIN

@interface DTXRunLoopSyncResource : DTXSyncResource

+ (instancetype)runLoopSyncResourceWithRunLoop:(CFRunLoopRef)runLoop;

@end

NS_ASSUME_NONNULL_END
