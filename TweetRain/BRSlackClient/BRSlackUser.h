//
//  BRSlackUser.h
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRSlackUser : NSObject

@property (nonatomic,strong) NSString *username; // e.g. "abc1234"
@property (nonatomic,strong) NSString *displayName; // e.g. "Alice"
@property (nonatomic,strong) NSString *userId;

@property (nonatomic,strong) NSURL *profileImageURL;

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
