#define __DEBUG

#define CARRIAGE @"\r\n"
#define PING_TIME 110

#import <Foundation/Foundation.h>
#import "IRCProtocol.h"
#import "IRCMessage.h"

@class IRCMessage;

typedef enum{
    kStateDisconnected = 0,
    kStateConnected = 1
} IRCConnectionState;

@protocol IRCConnectionControllerDelegate
-(void)clientHasReceivedBytes:(NSMutableArray<IRCMessage*>*)messageArray;
@end

@interface IRCConnectionController : NSObject <NSStreamDelegate> {
	NSInputStream *ingoingConnection;
	NSOutputStream *outgoingConnection;
	NSString *dataStream;
	NSMutableArray* parsedBuffer;
	BOOL authenticated;
	BOOL didSendPong;
	BOOL finishedRegistering;
	BOOL isAFK;
}

@property (assign) id<IRCConnectionControllerDelegate> delegate;
@property IRCConnectionState state;
@property (assign) int port;
@property int mode;
@property (strong) NSString* host;
@property (strong) NSString* nick;
@property (strong) NSString* name;
@property (strong) NSString* pass;
@property (assign) BOOL ssl;
@property BOOL printIncomingStream;

//Lib calls
-(void)establishConnection;
-(void)handleEventNone;
-(void)handleConnected;
-(void)handleBytesAvailable;
-(void)handleConnectionError;
-(void)handleDisconnected;
-(int)handshake;
-(int)ping;
// ----

-(int)send:(NSString*)cmd;
-(int)join:(NSString*)channel;
-(int)quit:(NSString*)reason;
-(int)AFK:(NSString*)reason;
-(int)exitAFK;
-(void)endConnection;
-(void)leaveChannel:(NSString*)channel;
-(void)clientHasReceivedBytes:(NSMutableArray*)messageArray;
-(void)msg:(NSString*)msg toChannel:(NSString*)channel;
-(void)connect;

@end
