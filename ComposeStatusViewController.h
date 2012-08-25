//
//  ComposeStatusViewController.h
//  flood
//
//  Created by b123400 on 22/8/12.
//
//

#import <Cocoa/Cocoa.h>
#import "Status.h"

@protocol ComposeStatusViewController <NSObject>

-(void)composeStatusViewController:(id)sender didEnded:(BOOL)sent;

@end

@interface ComposeStatusViewController : NSViewController {
	Status *inReplyTo;
	__unsafe_unretained NSTextView *contentTextView;
	
	NSPopover *popover;
}
@property (unsafe_unretained) IBOutlet NSTextView *contentTextView;
@property (strong, nonatomic) Status *inReplyTo;
@property (strong, nonatomic) NSPopover *popover;
@property (weak) IBOutlet NSButton *sendButton;

- (IBAction)sendButtonClicked:(id)sender;

@end
