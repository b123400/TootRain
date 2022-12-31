//
//  MissAccount.m
//  TweetRain
//
//  Created by b123400 on 2022/12/24.
//

#import "MisskeyAccount.h"

@implementation MisskeyAccount

- (instancetype)initWithMisskeyAccount:(BRMisskeyAccount *)account {
    if (self = [super init]) {
        self.misskeyAccount = account;
    }
    return self;
}

- (NSString *)identifier {
    return self.misskeyAccount.identifier;
}

- (NSString *)displayName {
    return self.misskeyAccount.displayName;
}

- (NSString *)shortDisplayName {
    return self.misskeyAccount.shortDisplayName;
}

- (void)deleteAccount {
    [self.misskeyAccount deleteAccount];
}

@end
