//
//  SearchWindowController.m
//  flood
//
//  Created by b123400 on 21/8/12.
//
//

#import "SearchWindowController.h"

@interface SearchWindowController ()

@end

@implementation SearchWindowController
@synthesize delegate;

-(id)init{
	return [self initWithWindowNibName:@"SearchWindowController"];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)finishButtonClicked:(id)sender {
	[delegate searchTermChangedTo:inputTextField.stringValue];
	[self close];
}
@end
