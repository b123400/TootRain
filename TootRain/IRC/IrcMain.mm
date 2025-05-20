#import <Foundation/Foundation.h>
#import "IRCConnectionController.h"

@interface testClass : NSObject {}
@end

@implementation testClass

-(void)clientHasReceivedBytes:(NSMutableArray*)messageArray{
    //Delegate method of ConnectionController class.
}
@end

int main1(int argc, const char * argv[])
{
    @autoreleasepool{
        
        testClass *c = [[testClass alloc] init];

        IRCConnectionController* client = [[IRCConnectionController alloc] init];

        [client setHost:@"light.wa.us.SwiftIRC.net"]; //first server of google list 
        [client setPort:6667];
        [client setNick:@"Test"];
        [client setName:@"Test"];
        [client setPass:@"Test"];
        [client setMode:0];
        [client setPrintIncomingStream:YES];
        [client setDelegate:c];

        [client connect];

        [client join:@"#example"];
        [client msg:@"Test message" toChannel:@"#example"];
        [client send:[NSString stringWithFormat:@":%@ PRIVMSG %@ :Test Message",client.nick,@"#example"]]; //Same command as the previous line, just using general send: method
        [client leaveChannel:@"#example"];

        while(1){
            sleep(5); //Just to keep alive.
        }

    }

    return 0;
}

/*THIS IS AN UNSTABLE VERSION, USE IT CAREFULLY

//WRITTEN BY @H3xept & @Jndok

*/
