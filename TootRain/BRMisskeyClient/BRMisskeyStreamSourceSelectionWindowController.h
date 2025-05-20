//
//  BRMisskeyStreamSourceSelectionWindowController.h
//  TweetRain
//
//  Created by b123400 on 2022/12/26.
//

#import <Cocoa/Cocoa.h>
#import "BRMisskeyAccount.h"
#import "BRMisskeyStreamSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRMisskeyStreamSourceSelectionWindowController : NSWindowController

@property (nonatomic, strong) BRMisskeyAccount *account;

- (NSArray<BRMisskeyStreamSource*> *)selectedSources;

@end

NS_ASSUME_NONNULL_END
