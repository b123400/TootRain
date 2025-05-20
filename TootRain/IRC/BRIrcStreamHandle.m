//
//  BRIrcStreamHandle.m
//  TweetRain
//
//  Created by b123400 on 2025/02/02.
//

#import "BRIrcStreamHandle.h"

@implementation BRIrcStreamHandle

-(void)clientHasReceivedBytes:(NSMutableArray<IRCMessage*>*)messageArray{
    //Delegate method of ConnectionController class.
    for (IRCMessage *message in messageArray) {
        NSLog(@"messageArray %@, %@, %@", message.rawString, message.command, message.trailing);
        if (self.onMessage && ([message.command isEqualTo:@"PRIVMSG"] || [message.command isEqualTo:@"NOTICE"]) && message.trailing) {
            self.onMessage(message.trailing);
        }
    }
}

- (void)disconnect {
    [self.cc endConnection];
}

@end
