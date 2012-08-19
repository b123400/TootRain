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
	NSTextField *contentTextField;
	WebImageView *profileImageView;
	NSTextField *nameField;
	NSTextField *usernameField;
}
@property (assign) IBOutlet NSTextField *contentTextField;
@property (assign) IBOutlet NSImageView *profileImageView;
@property (assign) IBOutlet NSTextField *nameField;
@property (assign) IBOutlet NSTextField *usernameField;

-(id)initWithStatus:(Status*)status;

@end
