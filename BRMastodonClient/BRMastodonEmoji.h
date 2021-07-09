//
//  BRMastodonEmoji.h
//  TweetRain
//
//  Created by b123400 on 2021/07/07.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRMastodonEmoji : NSObject

@property (nonatomic, strong) NSString *shortcode;
@property (nonatomic, strong) NSURL *staticURL;
@property (nonatomic, strong) NSURL *URL;

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
