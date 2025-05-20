//
//  NewUpdateStatus.m
//  TweetRain
//
//  Created by b123400 on 2024/10/04.
//

#import "NewUpdateStatus.h"

@implementation NewUpdateStatus

- (instancetype)init {
    if (self = [super init]) {
        self.statusID = [NSString stringWithFormat:@"NewUpdate-%@", [[NSUUID UUID] UUIDString]];
    }
    return self;
}

@end
