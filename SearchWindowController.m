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
    searchTextField.recentsAutosaveName = @"Search term";
    
    NSMenu *searchMenu = [[NSMenu alloc] init];
    NSMenuItem *recentItem = [[NSMenuItem alloc] init];
    recentItem.tag = NSSearchFieldRecentsMenuItemTag;
    [searchMenu addItem:recentItem];
    searchTextField.searchMenuTemplate = searchMenu;
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)finishButtonClicked:(id)sender {
    [searchTextField performClick:self];
    [self finishedEditing];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        [self finishedEditing];
        return YES;
    }
    return NO;
}

- (void)finishedEditing {
    [delegate searchTermChangedTo:searchTextField.stringValue];
    [self close];
}

@end
