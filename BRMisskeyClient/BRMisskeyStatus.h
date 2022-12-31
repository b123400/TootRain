//
//  BRMisskeyStatus.h
//  TweetRain
//
//  Created by b123400 on 2022/12/24.
//

#import <Foundation/Foundation.h>
#import "BRMisskeyUser.h"
#import "BRMisskeyEmoji.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRMisskeyStatus : NSObject

@property (nonatomic, strong) BRMisskeyUser *user;
@property (nonatomic, strong) NSArray<BRMisskeyEmoji*> *emojis;

@property (nonatomic, strong) NSString *statusID;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString * _Nullable contentWarning;

@property (nonatomic, strong) BRMisskeyStatus *renote;


- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

- (NSAttributedString *)attributedStringWithEmojisReplaced;

@end

NS_ASSUME_NONNULL_END
