//
//  BRMastodonClient.h
//  TweetRain
//
//  Created by b123400 on 2021/06/27.
//

#import <Foundation/Foundation.h>
#import "BRMastodonApp.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRMastodonClient : NSObject

+ (instancetype)shared;

- (void)registerAppFor:(NSString*)hostname completionHandler:(void (^)(BRMastodonApp *app, NSError *error))callback;

@end

NS_ASSUME_NONNULL_END
