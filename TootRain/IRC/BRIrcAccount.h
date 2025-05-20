//
//  BRIrcAccount.h
//  TweetRain
//
//  Created by b123400 on 2025/01/20.
//

#import "Account.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRIrcAccount : Account

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, assign) BOOL tls;
@property (nonatomic, strong) NSString *nick;
@property (nonatomic, strong, nullable) NSString *pass;
@property (nonatomic, strong) NSArray<NSString *> *channels;

+ (NSArray<BRIrcAccount*> *)allAccounts;
- (void)save;

@end

NS_ASSUME_NONNULL_END
