#import "IRCProtocol.h"
#import "IRCMessage.h"

@implementation IRCProtocol

+(instancetype)sharedInstance{
	static IRCProtocol *privateProtocolController = nil;
	if(!privateProtocolController){
		privateProtocolController = [[self alloc] init];
	}
	return privateProtocolController;
}

-(NSString *)craftHandshakePacket:(NSString*)nick Password:(NSString*)pass Mode:(int)mode RealName:(NSString*)name
{
	return [NSString stringWithFormat:@"PASS %@\r\nNICK %@\r\nUSER %@ %d * :%@", pass, nick, nick, mode, name];
}

-(NSString *)craftJoinPacket:(NSString*)channel{
	return [NSString stringWithFormat:@"JOIN %@",channel];
}

-(NSMutableArray*)parse:(NSString*)dataStream{
	NSMutableArray* data = [[NSMutableArray alloc] init];
	for(NSString *msgLine in [dataStream componentsSeparatedByString:@"\r\n"]) {
        if (![msgLine length]) continue;

        IRCMessage *msg = [[IRCMessage alloc] init];

        {
            NSArray *components = [msgLine componentsSeparatedByString:@" "];
            msg.prefix = components[0];
            if([msg.prefix hasPrefix:@":"]){
                msg.prefix = [msg.prefix substringFromIndex:1];
            }
        }

        {
            NSArray *components = [msgLine componentsSeparatedByString:@" "];
            if (components.count >= 2) {
                msg.command = components[1];
            }
        }
        
        {
            NSArray *components = [msgLine componentsSeparatedByString:@" "];
            if (components.count >= 3) {
                msg.params = components[2];
            }
        }
        {
            NSArray *components = [msgLine componentsSeparatedByString:[NSString stringWithFormat:@"%@ :",msg.params]];
            if (components.count >= 2) {
                msg.trailing = components[1];
            }
        }

        msg.rawString = msgLine;
        
        [data addObject:msg];
	}

	return data;
}

@end
