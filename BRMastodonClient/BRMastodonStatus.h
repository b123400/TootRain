//
//  BRMastodonStatus.h
//  TweetRain
//
//  Created by b123400 on 2021/07/05.
//

#import <Foundation/Foundation.h>
#import "BRMastodonUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRMastodonStatus : NSObject

@property (nonatomic, strong) BRMastodonUser *user;

@property (nonatomic, strong) NSString *statusID;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSString *text;

@property (nonatomic, assign) BOOL favourited;
@property (nonatomic, assign) BOOL bookmarked;
@property (nonatomic, assign) BOOL reblogged;

- (instancetype)initWithJSONDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
