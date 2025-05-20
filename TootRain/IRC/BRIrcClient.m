//
//  BRIrcClient.m
//  TweetRain
//
//  Created by b123400 on 2025/02/02.
//

#import "BRIrcClient.h"
#import "IRCConnectionController.h"

@implementation BRIrcClient

+ (instancetype)shared {
    static BRIrcClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BRIrcClient alloc] init];
    });
    return instance;
}

- (BRIrcStreamHandle *)streamWithAccount:(BRIrcAccount *)account {
    BRIrcStreamHandle *handle = [[BRIrcStreamHandle alloc] init];
    
    IRCConnectionController* cc = [[IRCConnectionController alloc] init];
    handle.cc = cc;
    cc.host = account.host; // @"irc.libera.chat";
    cc.port = (int)account.port;
    cc.ssl = account.tls;
    cc.nick = account.nick;
    cc.pass = account.pass;
    cc.mode = 0;
    cc.printIncomingStream = YES;
    cc.delegate = handle;
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        [cc connect];
        for (NSString *channel in account.channels) {
            [cc join:channel];
        }
    });
    return handle;
}

@end
