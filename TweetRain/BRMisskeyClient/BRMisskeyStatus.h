//
//  BRMisskeyStatus.h
//  TweetRain
//
//  Created by b123400 on 2022/12/24.
//

#import <Foundation/Foundation.h>
#import "BRMisskeyUser.h"
#import "BRMisskeyEmoji.h"
#import "BRMisskeyAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRMisskeyStatus : NSObject

@property (nonatomic, strong) BRMisskeyAccount *account;
@property (nonatomic, strong) BRMisskeyUser *user;
@property (nonatomic, strong, nullable) NSArray<BRMisskeyEmoji*> *emojis;

@property (nonatomic, strong) NSString *statusID;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString * _Nullable contentWarning;

@property (nonatomic, strong) BRMisskeyStatus *renote;


- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary account:(BRMisskeyAccount *)account;

- (NSAttributedString *)attributedStringWithEmojisReplaced;
- (NSAttributedString *)attributedContentWarningWithEmojisReplaced;

@end

NS_ASSUME_NONNULL_END
