//
//  BRMastodonSourceSelectionWindowController.h
//  TweetRain
//
//  Created by b123400 on 2022/11/29.
//

#import <Cocoa/Cocoa.h>
#import "BRMastodonAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRMastodonSourceSelectionWindowController : NSWindowController

- (instancetype)initWithAccount:(BRMastodonAccount *)account;

- (BRMastodonStreamSource)selectedSource;
- (NSString *)hashtag;
- (NSString *)listId;
- (NSString *)listName;

@end

NS_ASSUME_NONNULL_END
