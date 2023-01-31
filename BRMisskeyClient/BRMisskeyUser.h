//
//  BRMisskeyUser.h
//  TweetRain
//
//  Created by b123400 on 2022/12/23.
//

#import <Foundation/Foundation.h>
#import "BRMisskeyEmoji.h"
#import "BRMisskeyAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRMisskeyUser : NSObject

@property (nonatomic, strong) BRMisskeyAccount *account;
@property (nonatomic, strong) NSString *username; // e.g. "b"
@property (nonatomic, strong) NSString *displayName; // e.g. "b123400"
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSURL *profileImageURL;
@property (nonatomic, strong, nullable) NSString *host; // misskey.io, this exists when the user is from a remote server

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary account:(BRMisskeyAccount * _Nullable)account;

- (NSAttributedString *)attributedScreenName;

@end

NS_ASSUME_NONNULL_END
