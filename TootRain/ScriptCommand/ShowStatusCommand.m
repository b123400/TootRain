//
//  MyCommand.m
//  TweetRain
//
//  Created by b123400 on 2023/02/23.
//

#import "ShowStatusCommand.h"
#import <Cocoa/Cocoa.h>
#import "StreamController.h"
#import "DummyStatus.h"
#import "User.h"

@implementation ShowStatusCommand

- (id)performDefaultImplementation {
    NSString *text = [self directParameter];
    NSDictionary *args = [self evaluatedArguments];
    NSString *profileImageURLString = args[@"profileImageURL"];
    NSURL *profileImageURL = [NSURL URLWithString:profileImageURLString];
    StreamController *streamController = [StreamController shared];
    DummyStatus *status = [[DummyStatus alloc] init];
    NSDictionary *options = @{
        NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
        NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)
    };
    status.attributedText = [[NSAttributedString alloc] initWithHTML:[text dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:options
                                                  documentAttributes:nil];
    User *user = [[User alloc] init];
    user.profileImageURL = profileImageURL;
    status.user = user;
    [streamController showStatus:status];
    return nil;
}

@end
