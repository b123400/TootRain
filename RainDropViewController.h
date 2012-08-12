//
//  RainViewController.h
//  flood
//
//  Created by b123400 on 12/8/12.
//
//

#import <Cocoa/Cocoa.h>
#import "Status.h"
#import "RainDropView.h"

@interface RainDropViewController : NSViewController <RainDropViewDelegate> {
	NSTextField *contentTextField;
	
	Status *status;
}

@property (assign) IBOutlet NSTextField *contentTextField;
@property (retain,nonatomic) Status *status;

- (id)initWithStatus:(Status*)_status;

-(void)startAnimation;

@end
