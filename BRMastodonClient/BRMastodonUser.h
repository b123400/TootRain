//
//  BRMastodonUser.h
//  TweetRain
//
//  Created by b123400 on 2021/07/05.
//

#import <Foundation/Foundation.h>
#import "BRMastodonAccount.h"
#import "BRMastodonEmoji.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRMastodonUser : NSObject

@property (nonatomic, strong) BRMastodonAccount *account;

@property (nonatomic,strong) NSString *username; // e.g. "b"
@property (nonatomic,strong) NSString *accountName; // e.g. "b" "b@is-he.re"
@property (nonatomic,strong) NSString *displayName; // e.g. "b123400"
@property (nonatomic,strong) NSString *userID;
@property (nonatomic,strong) NSString *note;

@property (nonatomic,strong) NSURL *profileImageURL;
@property (nonatomic,strong) NSURL *URL;

@property (nonatomic, strong) NSArray<BRMastodonEmoji*> *emojis;

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary account:(BRMastodonAccount *)account;

- (NSAttributedString *)attributedScreenName;

@end

NS_ASSUME_NONNULL_END
