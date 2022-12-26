//
//  BRMisskeyAccount.h
//  TweetRain
//
//  Created by b123400 on 2022/12/23.
//

#import <Foundation/Foundation.h>
#import "BRMisskeyUser.h"
#import "BRMisskeyStreamSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRMisskeyAccount : NSObject

@property (nonatomic, strong) NSString *hostName;
@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong, nullable) NSString *accessToken;
@property (nonatomic, strong) NSArray <BRMisskeyStreamSource *> *streamSources;

+ (NSArray<BRMisskeyAccount*> *)allAccounts;

- (instancetype)initNewAccountWithHostName:(NSString *)hostName
                               accessToken:(NSString *)accessToken
                                      user:(BRMisskeyUser *)user;

- (void)save;

- (NSString *)shortDisplayName;
- (NSString *)identifier;
- (NSString *)displayNameForStreamSource;
- (void)deleteAccount;

@end

NS_ASSUME_NONNULL_END
