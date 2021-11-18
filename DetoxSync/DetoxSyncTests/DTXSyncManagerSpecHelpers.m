//
//  DTXSyncManagerSpecHelpers.m
//  DetoxSyncTests
//
//  Created by asaf korem on 18/11/2021.
//  Copyright © 2021 wix. All rights reserved.
//

#import "DTXSyncManagerSpecHelpers.h"

#import <DetoxSync/DTXSyncManager.h>
#import <DetoxSync/DTXJSTimerSyncResource.h>

#import "NSString+SyncResource.h"
#import "RCTFakes.h"

@interface DTXSyncManager (ForTesting)

+ (void)registerSyncResource:(DTXSyncResource*)syncResource;

@end

@implementation NSDictionary (RoundedTimer)

- (NSDictionary<NSString *,id> *)roundedTimerValue {
  NSMutableDictionary<NSString *,id> *mappedTimer = [self mutableCopy];
  for (NSString *key in self) {
    if ([key isEqualToString:@"time_until_fire"]) {
      mappedTimer[key] = @(floorf([self[key] floatValue] + 0.5f));
    }
  }
  return mappedTimer;
}

@end

NSDictionary<NSString *,id> *DTXAwaitStatus(void) {
  __block NSDictionary<NSString *,id> * _Nullable syncStatus;
  waitUntil(^(DoneCallback done) {
    [DTXSyncManager statusWithCompletionHandler:^(NSDictionary<NSString *,id> *status) {
      syncStatus = status;
      done();
    }];
  });

  assert(syncStatus);
  return syncStatus;
}

NSArray<NSDictionary<NSString *,id> *> *DTXFindResources(
    NSString *name, NSArray<NSDictionary<NSString *,id> *> *resources) {
  NSMutableArray<NSDictionary<NSString *,id> *> *matchingResources = [NSMutableArray array];
  for (NSDictionary<NSString *,id> *resource in resources) {
    if ([resource[NSString.dtx_resourceNameKey] isEqualToString:name]) {
      [matchingResources addObject:resource];
    }
  }
  return matchingResources;
}

NSDateFormatter *DTXDateFormatter(void) {
  NSDateFormatter* formatter = [NSDateFormatter new];
  [formatter setTimeZone:[NSTimeZone systemTimeZone]];
  [formatter setLocale:[NSLocale currentLocale]];
  [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss Z"];

  return formatter;
}

NSArray<NSDictionary<NSString *,id> *> *DTXMapTimers(NSArray<NSDictionary<NSString *,id> *> *timers) {
  NSMutableArray<NSDictionary<NSString *,id> *> *mappedTimers = [timers mutableCopy];
  [timers enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> *timer, NSUInteger index, BOOL * __unused stop) {
    [mappedTimers replaceObjectAtIndex:index withObject:timer.roundedTimerValue];
  }];

  return mappedTimers;
}

void DTXConnectWithJSTimerSyncResource(void) {
  DTXJSTimerSyncResource* resource = [DTXJSTimerSyncResource new];
  [DTXSyncManager registerSyncResource:resource];
}

void DTXCreateFakeJSTimer(double callbackID, NSTimeInterval duration, double schedulingTime,
                          BOOL repeats) {
  RCTTiming *fakeTiming = [[RCTTiming alloc] init];
  [fakeTiming createTimer:callbackID duration:duration jsSchedulingTime:schedulingTime repeats:repeats];
}

void DTXRegisterSingleEvent(NSString *event, NSString * _Nullable object) {
  id trackEvent = [DTXSyncManager trackEventWithDescription:event objectDescription:object];
  [DTXSyncManager registerSyncResource:trackEvent];
}
