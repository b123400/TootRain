//
//  BRMisskeyUser.h
//  TweetRain
//
//  Created by b123400 on 2022/12/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRMisskeyUser : NSObject

@property (nonatomic,strong) NSString *username; // e.g. "b"
@property (nonatomic,strong) NSString *displayName; // e.g. "b123400"
@property (nonatomic,strong) NSString *userID;

@property (nonatomic,strong) NSURL *profileImageURL;

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
