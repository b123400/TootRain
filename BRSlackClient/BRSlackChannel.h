//
//  BRSlackChannel.h
//  TweetRain
//
//  Created by b123400 on 2021/07/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRSlackChannel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *channelId;

- (instancetype)initWithAPIJSON:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
