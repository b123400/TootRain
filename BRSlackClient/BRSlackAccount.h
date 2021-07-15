//
//  BRSlackAccount.h
//  TweetRain
//
//  Created by b123400 on 2021/07/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRSlackAccount : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, strong) NSString *teamId;
@property (nonatomic, strong) NSString *teamName;
@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSDictionary *responseHeaderWithCookies;

+ (NSArray *)allAccounts;

- (void)save;
- (void)deleteAccount;

- (NSDictionary *)headersForRequest;

@end

NS_ASSUME_NONNULL_END
