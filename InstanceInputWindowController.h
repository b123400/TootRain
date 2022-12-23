//
//  InstanceInputView.h
//  TweetRain
//
//  Created by b123400 on 2021/07/02.
//

#import <Cocoa/Cocoa.h>
#import "SettingManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface InstanceInputWindowController : NSWindowController

@property (weak) IBOutlet NSTextField *hostNameTextField;
@property (nonatomic, assign) SettingAccountType accountType;

- (NSString*)hostName;

@end

NS_ASSUME_NONNULL_END
