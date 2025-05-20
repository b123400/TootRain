//
//  BRMisskeyAccount.h
//  TweetRain
//
//  Created by b123400 on 2022/12/23.
//

#import <Foundation/Foundation.h>
#import "BRMisskeyStreamSource.h"
#import "BRMisskeyEmoji.h"
#import "Account.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRMisskeyAccount : Account

@property (nonatomic, strong) NSString *hostName;
@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong, nullable) NSString *accessToken;
@property (nonatomic, strong) NSArray <BRMisskeyStreamSource *> *streamSources;

+ (NSArray<BRMisskeyAccount*> *)allAccounts;

- (instancetype)initNewAccountWithHostName:(NSString *)hostName
                               accessToken:(NSString *)accessToken
                                 accountId:(NSString *)accountId
                                  username:(NSString *)username;

- (void)save;

- (NSString *)shortDisplayName;
- (NSString *)identifier;
- (NSString *)displayNameForStreamSource;
- (void)deleteAccount;
- (void)setEmojiDict:(NSDictionary<NSString *, BRMisskeyEmoji *> *)dict;
- (NSURL *)urlForEmoji:(NSString *)emoji host:(NSString * _Nullable)host;
- (NSAttributedString *)attributedString:(NSString *)string
                                withHost:(NSString * _Nullable)host
                          emojisReplaced:(NSArray<BRMisskeyEmoji*>  * _Nullable)emojis;

@end

NS_ASSUME_NONNULL_END
