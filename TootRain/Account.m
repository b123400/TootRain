//
//  Account.m
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import "Account.h"

@implementation Account

- (NSString *)displayName {
    return @"[Account]";
}

- (NSString *)shortDisplayName {
    return self.displayName;
}

- (NSString *)identifier {
    return @"";
}

- (NSImage *)serviceImage {
    return nil;
}

- (void)deleteAccount {
    
}

@end
