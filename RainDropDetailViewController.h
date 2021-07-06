//
//  RainDropDetailViewController.h
//  flood
//
//  Created by b123400 on 19/8/12.
//
//

#import <Cocoa/Cocoa.h>
#import "Status.h"
#import "WebImageView.h"

@interface RainDropDetailViewController : NSViewController{
	Status *status;
	NSTextField *__weak contentTextField;
	WebImageView *__weak profileImageView;
	NSTextField *__weak nameField;
	NSTextField *__weak usernameField;
}
@property (weak) IBOutlet NSTextField *contentTextField;
@property (weak) IBOutlet NSImageView *profileImageView;
@property (weak) IBOutlet NSTextField *nameField;
@property (weak) IBOutlet NSTextField *usernameField;
@property (weak) IBOutlet NSButton *repostButton;
@property (weak) IBOutlet NSButton *favButton;

-(id)initWithStatus:(Status*)status;

@end
