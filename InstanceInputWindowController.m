//
//  InstanceInputView.m
//  TweetRain
//
//  Created by b123400 on 2021/07/02.
//

#import "InstanceInputWindowController.h"

@interface InstanceInputWindowController ()

@end

@implementation InstanceInputWindowController

- (instancetype)init {
    return [self initWithWindowNibName:@"InstanceInputWindowController"];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (NSString*)hostName {
    return self.hostNameTextField.stringValue;
}

- (IBAction)authorizeButtonClicked:(id)sender {
    [self.window.sheetParent endSheet:self.window
                           returnCode:NSModalResponseOK];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self.window.sheetParent endSheet:self.window
                           returnCode:NSModalResponseCancel];
}

@end
