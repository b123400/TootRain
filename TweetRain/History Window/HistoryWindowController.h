//
//  HistoryWindowController.h
//  TweetRain
//
//  Created by b123400 on 2023/11/22.
//

#import <Cocoa/Cocoa.h>
#import "Status.h"

NS_ASSUME_NONNULL_BEGIN

@interface HistoryWindowController : NSWindowController

+ (instancetype)shared;
- (void)addStatus:(Status *)s;
@end

NS_ASSUME_NONNULL_END
