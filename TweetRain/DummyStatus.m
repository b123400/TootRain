//
//  DummyStatus.m
//  TweetRain
//
//  Created by b123400 on 2021/07/07.
//

#import "DummyStatus.h"

@implementation DummyStatus

- (instancetype)init {
    if (self = [super init]) {
        self.statusID = [NSString stringWithFormat:@"Dummy-%@", [[NSUUID UUID] UUIDString]];
    }
    return self;
}

@end
