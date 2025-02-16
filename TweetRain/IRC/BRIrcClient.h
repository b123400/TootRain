//
//  BRIrcClient.h
//  TweetRain
//
//  Created by b123400 on 2025/02/02.
//

#import <Foundation/Foundation.h>
#import "BRIrcStreamHandle.h"
#import "BRIrcAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRIrcClient : NSObject

+ (instancetype)shared;

- (BRIrcStreamHandle *)streamWithAccount:(BRIrcAccount *)account;

@end

NS_ASSUME_NONNULL_END
