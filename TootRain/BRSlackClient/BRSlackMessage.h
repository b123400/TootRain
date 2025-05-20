//
//  BRSlackMessage.h
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import <Foundation/Foundation.h>
#import "BRSlackAccount.h"
#import "BRSlackUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSlackMessage : NSObject

@property (nonatomic, strong) BRSlackAccount *account;
@property (nonatomic, strong, nullable) BRSlackUser *user;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSArray<NSString *> *emojis;
@property (nonatomic, nullable, strong) NSURL *url;

- (instancetype)initWithJSONDict:(NSDictionary *)dict user:(BRSlackUser *)user account:(BRSlackAccount *)account;
- (NSAttributedString *)attributedString;
- (NSAttributedString *)attributedStringWithEmojisReplaced;

@end

NS_ASSUME_NONNULL_END
