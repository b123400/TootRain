#import <Foundation/Foundation.h>

@class IRCMessage;

@interface IRCProtocol : NSObject{

}
+(instancetype)sharedInstance;
-(NSMutableArray*)parse:(NSString*)dataStream;
-(NSString *)craftHandshakePacket:(NSString*)nick Password:(NSString*)pass Mode:(int)mode RealName:(NSString*)name;
-(NSString *)craftJoinPacket:(NSString*)channel;
@end