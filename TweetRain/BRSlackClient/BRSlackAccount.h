//
//  BRSlackAccount.h
//  TweetRain
//
//  Created by b123400 on 2021/07/11.
//

#import <Foundation/Foundation.h>
#import "Account.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSlackAccount : Account

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, strong) NSString *teamId;
@property (nonatomic, strong) NSString *teamName;
@property (nonatomic, strong) NSArray<NSString*> *channelIds;
@property (nonatomic, strong) NSArray<NSString*> *channelNames;
@property (nonatomic, strong) NSString *threadId;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSDictionary *responseHeaderWithCookies;

+ (NSArray *)allAccounts;

- (void)save;
- (void)deleteAccount;

- (void)setEmojiDict:(NSDictionary<NSString *, NSString *> *)dict;
- (NSString *)urlForEmoji:(NSString *)emoji;

- (NSDictionary *)headersForRequest;
- (NSString *)displayName;
- (NSString *)shortDisplayName;

@end

NS_ASSUME_NONNULL_END
