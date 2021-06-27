//
//  MastodonApp.h
//  TweetRain
//
//  Created by b123400 on 2021/06/27.
//

#import <Foundation/Foundation.h>
#define MASTODON_REDIRECT_DEST @"urn:ietf:wg:oauth:2.0:oob"

NS_ASSUME_NONNULL_BEGIN

@interface BRMastodonApp : NSObject

@property (strong, nonatomic) NSString *hostName;
@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) NSString *clientSecret;

+ (instancetype)appWithHostname:(NSString *)hostName;

- (instancetype)initWithHostName:(NSString *)hostName
                        clientId:(NSString *)clientId
                    clientSecret:(NSString *)clientSecret;
- (void)save;
- (NSURL *)authorisationURL;

@end

NS_ASSUME_NONNULL_END
