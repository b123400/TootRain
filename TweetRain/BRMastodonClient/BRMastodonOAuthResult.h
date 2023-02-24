//
//  BRMastodonOAuthResult.h
//  TweetRain
//
//  Created by b123400 on 2021/07/02.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRMastodonOAuthResult : NSObject

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong, nullable) NSString *refreshToken;
@property (nonatomic, strong, nullable) NSNumber *expiresIn;

@end

NS_ASSUME_NONNULL_END
