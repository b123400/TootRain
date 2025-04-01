//
//  BRMastodonInstanceInfo.h
//  TweetRain
//
//  Created by b123400 on 2025/04/01.
//

#import <Foundation/Foundation.h>
#import "BRMastodonAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRMastodonInstanceInfo : NSObject

// The name of the Mastodon-compatible software used,
// e.g. Pleroma, Akkoma
@property (nonatomic, assign) BRMastodonInstanceSoftware software;

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
