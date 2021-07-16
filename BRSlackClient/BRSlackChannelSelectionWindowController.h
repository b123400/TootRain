//
//  BRSlackChannelSelectionWindowController.h
//  TweetRain
//
//  Created by b123400 on 2021/07/14.
//

#import <Cocoa/Cocoa.h>
#import "BRSlackChannel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRSlackChannelSelectionWindowController : NSWindowController

@property (weak) IBOutlet NSPopUpButton *dropdown;
@property (weak) IBOutlet NSButton *okButton;
@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, readonly, nullable) BRSlackChannel *selectedChannel;

@end

NS_ASSUME_NONNULL_END
