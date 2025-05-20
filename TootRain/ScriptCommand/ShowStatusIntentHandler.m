//
//  ShowStatusIntentHandler.m
//  TweetRain
//
//  Created by b123400 on 2023/02/24.
//

#import "ShowStatusIntentHandler.h"
#import "StreamController.h"
#import "DummyStatus.h"

@implementation ShowStatusIntentHandler

- (void)handleShowStatus:(ShowStatusIntent *)intent completion:(void (^)(ShowStatusIntentResponse *response))completion NS_SWIFT_NAME(handle(intent:completion:))  API_AVAILABLE(macos(11.0)){
    if (@available(macOS 11.0, *)) {
        Status *s = [[DummyStatus alloc] init];
        NSDictionary *options = @{
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)
        };
        s.attributedText = [[NSAttributedString alloc] initWithHTML:[(intent.text ?: @"null") dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:options
                                                 documentAttributes:nil];
        User *user = [[User alloc] init];
        user.profileImageURL = intent.avatarURL;
        s.user = user;
        [[StreamController shared] showStatus:s];
        BOOL isWindowVisible = [[[[NSApplication sharedApplication] windows] firstObject] isVisible];
        ShowStatusIntentResponse *response = [[ShowStatusIntentResponse alloc] initWithCode:isWindowVisible ? ShowStatusIntentResponseCodeSuccess : ShowStatusIntentResponseCodeContinueInApp
                                                                               userActivity:nil];
        completion(response);
    }
}

@end
