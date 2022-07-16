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

@property (weak) IBOutlet NSTableView *channelsTableView;
@property (weak) IBOutlet NSTextField *threadURLField;
@property (weak) IBOutlet NSButton *okButton;

@property (nonatomic, strong) NSArray<BRSlackChannel*> *channels;
@property (nonatomic, readonly) NSArray<BRSlackChannel*> *selectedChannels;
- (void)setSelectedChannelIds:(NSArray<NSString *> *)channelIds;
@property (nonatomic, nullable) NSString* selectedThreadId;

@end

NS_ASSUME_NONNULL_END
