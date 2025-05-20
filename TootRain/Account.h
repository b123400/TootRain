//
//  Account.h
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Account : NSObject

- (NSString *)identifier;
- (NSString *)displayName;
- (NSString *)shortDisplayName;
- (NSImage *)serviceImage;
- (void)deleteAccount;

@end

NS_ASSUME_NONNULL_END
