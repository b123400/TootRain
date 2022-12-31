//
//  BRMisskeyEmoji.h
//  TweetRain
//
//  Created by b123400 on 2022/12/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRMisskeyEmoji : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *URL;

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
