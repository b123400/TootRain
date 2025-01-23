#import "IRCConnectionController.h"

@interface IRCConnectionController()
-(const char*)simpleCStringConvert:(NSString*)string;
-(void)sendPingback;
@end

@implementation IRCConnectionController

#ifdef __DEBUG
	const char *connected_host;
	int connected_port;
#endif

/* Tool Functions/Methods */

-(const char*)simpleCStringConvert:(NSString*)string
{
	return [string cStringUsingEncoding:[NSString defaultCStringEncoding]];
}

/* Connection Handling Section */

-(instancetype)init 
{
	self = [super init];
	self.state = kStateDisconnected;
	self.host = @"localhost";
	self.port = 6667;
	self.nick = @"IRCUser";
	self.name = @"IRCUser";
	self.pass = @"IRCUserPassword";
	self.mode = 0;
	self->didSendPong = NO;
	self->authenticated = NO;
	self->finishedRegistering = NO;
	self->isAFK = NO;

	return self;
}

-(void)establishConnection
{
    CFReadStreamRef ingoingConnectionCF;
    CFWriteStreamRef outgoingConnectionCF;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.host, self.port, &ingoingConnectionCF, &outgoingConnectionCF);
    ingoingConnection = (NSInputStream *)CFBridgingRelease(ingoingConnectionCF);
    outgoingConnection = (NSOutputStream *)CFBridgingRelease(outgoingConnectionCF);

	[ingoingConnection setDelegate:self];
	[outgoingConnection setDelegate:self];

	[ingoingConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outgoingConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    BOOL ssl = YES;
    if (ssl) {
        NSDictionary *dict = @{
            (NSString*)kCFStreamSSLValidatesCertificateChain: (id)kCFBooleanFalse,     // allow self-signed certificate
            (NSString*)kCFStreamSSLLevel: @"kCFStreamSocketSecurityLevelTLSv1_2"    // don't understand, why there isn't a constant for version 1.2
        };
        CFDictionaryRef tlsSettings = (__bridge CFDictionaryRef)dict;
        BOOL sslSetRead = CFReadStreamSetProperty(ingoingConnectionCF, kCFStreamPropertySSLSettings, tlsSettings);
        BOOL sslSetWrite = CFWriteStreamSetProperty(outgoingConnectionCF, kCFStreamPropertySSLSettings, tlsSettings);

        if (!sslSetRead || !sslSetWrite) {
//            throw ConnectionError.sslConfigurationFailed
            NSLog(@"oh no");
        }
    }

	[ingoingConnection open];
	[outgoingConnection open];

#ifdef __DEBUG
	connected_host = [self.host UTF8String];
	connected_port = self.port;
#endif

	[[NSRunLoop currentRunLoop] run];
}

-(void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
	switch(streamEvent){
		case NSStreamEventNone:
			[self handleEventNone];
			break;
		case NSStreamEventOpenCompleted:
			[self handleConnected];
			break;
		case NSStreamEventHasBytesAvailable:
			[self handleBytesAvailable];
			break;
		case NSStreamEventErrorOccurred:
			[self handleConnectionError];
			break;
		case NSStreamEventEndEncountered:
			[self handleDisconnected];
			break;
		case NSStreamEventHasSpaceAvailable:
			if(!self->authenticated) {
				int result = [self handshake];
				if(result == 0) {

#ifdef __DEBUG
	fprintf(stdout, "[+] Handshake successful!\n");
#endif	

					self->authenticated = YES;
					[NSTimer scheduledTimerWithTimeInterval:PING_TIME target:self selector:@selector(ping) userInfo:nil repeats:YES];
				} else if(result == 1) {
					fprintf(stderr, "[!] Handshake has failed. Cooldown for 10 secs...\n");
					sleep(10);
				} else if(result == -1) {
					fprintf(stderr, "[!] Handshake has failed. Please connect to the server first.\n");
				}
			}
			
			break;
	}
}

-(void)handleEventNone
{
	return;
}

-(void)handleConnected
{	
	if(self.state == kStateDisconnected){
#ifdef __DEBUG
		fprintf(stdout, "[~] Connected to: %s:%d\n", connected_host, connected_port);
#endif	
		self.state = kStateConnected;
	}
}

-(void)handleBytesAvailable
{
	uint8_t buf[2048];
	int rLen; 

	while([ingoingConnection hasBytesAvailable]) {
		rLen = [ingoingConnection read:buf maxLength:sizeof(buf)];
		if(rLen > 0) {
			self->dataStream = [[NSString alloc] initWithBytes:buf length:rLen encoding:NSASCIIStringEncoding];
		}
		if(self->dataStream) {
			if(self.printIncomingStream == YES)
#ifdef __DEBUG
				fprintf(stdout, "%s", [self simpleCStringConvert:self->dataStream]);
#endif	
			[self parseBuffer:self->dataStream];

		}
	}
}

-(void)handleConnectionError
{
#ifdef __DEBUG
	fprintf(stderr, "[!] There was an error while connecting to %s:%d", connected_host, connected_port);
#endif	
}

-(void)handleDisconnected
{ 
#ifdef __DEBUG
	fprintf(stdout, "[~] Disconnected from %s:%d", connected_host, connected_port);
#endif	

	self->authenticated = nil;
	self->didSendPong = nil;
	self.state = kStateDisconnected;
	self->finishedRegistering = NO;
}

-(int)send:(NSString*)cmd
{
	if(self.state == kStateConnected){
		const uint8_t* buffer = (const uint8_t*)[[NSString stringWithFormat:@"%@%@", cmd, CARRIAGE] UTF8String];
		if([outgoingConnection write:buffer maxLength:strlen((char *)buffer)] == 0)
			return 0;
		else
			return 1;
	}

	return -1;
}

/* Command Section */

-(int)handshake
{
#ifdef __DEBUG
	fprintf(stdout, "[+] Sending handshake...\n");
#endif

	NSString *hndshk_packet = [[IRCProtocol sharedInstance] craftHandshakePacket:self.nick Password:self.pass Mode:self.mode RealName:self.name];
	if([self send:hndshk_packet] == -1) {
		fprintf(stderr, "[!] Error: Are you connected?\n");
		return -1;
	}

	return 0;
}

-(int)join:(NSString*)channel
{
	if(self->finishedRegistering){

#ifdef __DEBUG
	fprintf(stdout, "[+] Joining channel...\n");
#endif

		NSString *join_packet = [[IRCProtocol sharedInstance] craftJoinPacket:channel];
		if([self send:join_packet] == -1) {
			fprintf(stderr, "[!] Error: Are you connected?\n");
			return -1;
		}

	} else{
		sleep(3);
		[self join:channel];
	}

	return 0;
}

-(int)quit:(NSString*)reason
{

	if(self->finishedRegistering){

#ifdef __DEBUG
	fprintf(stdout, "[+] Quitting...\n");
#endif

		if([self send:[NSString stringWithFormat:@"QUIT :%@", reason]] == -1) {
			fprintf(stderr, "[!] Error: Are you connected?\n");
			return -1;
		}
	}

	return 0;
}

-(int)AFK:(NSString*)reason;
{
	if(self->finishedRegistering){

#ifdef __DEBUG
	fprintf(stdout, "[+] Setting AFK...\n");
#endif

		if([self send:[NSString stringWithFormat:@"AWAY :%@", reason]] == -1) {
			fprintf(stderr, "[!] Error: Are you connected?\n");
			return -1;
		}

		self->isAFK = YES;
	}

	return 0;
}

-(int)exitAFK
{

	if (!(self->isAFK)) {
		return -1;
	}

	if(self->finishedRegistering){

#ifdef __DEBUG
	fprintf(stdout, "[+] Exiting AFK...\n");
#endif

		if([self send:@"AWAY"] == -1) {
			fprintf(stderr, "[!] Error: Are you connected?\n");
			return -1;
		}
	}

	return 0;
}

-(int)ping
{
	int conn = [self send:@"PING :hey!"];
	if(conn != -1){
		return 1;
	}
	return 0;
}

-(void)parseBuffer:(NSString*)dataStream
{	
	if(self->didSendPong == NO && self->authenticated == YES){
		[self sendPingback];
	}
	[self clientHasReceivedBytes:[[IRCProtocol sharedInstance] parse:self->dataStream]]; 
}

-(void)clientHasReceivedBytes:(NSMutableArray*)messageArray
{
	if(self.delegate) {
		[self.delegate clientHasReceivedBytes:messageArray];
	} else { 
#ifdef __DEBUG
		fprintf(stdout, "[!] No delegate has been set!");
#endif
	}

	if(self->finishedRegistering == NO) {
		for(IRCMessage* msg in messageArray) {
        	if([msg.command isEqual:@"255"]) {
            	self->finishedRegistering = YES;
        	}
    	}
	}
}

-(void)endConnection
{
	[ingoingConnection close];
	[outgoingConnection close];
	[self handleDisconnected];
}

-(void)sendPingback
{
	if(self->didSendPong == NO && self->authenticated == YES){
		NSArray *arr = [self->dataStream componentsSeparatedByString:@"\n"];
		for (int i = 0; i < [arr count]; ++i) {
			if ([arr[i] hasPrefix:@"PING"]) {
				NSString *pingback = [arr[i] componentsSeparatedByString:@"PING :"][1];
				[self send:[NSString stringWithFormat:@"PONG :%@", pingback]];
				didSendPong = YES;
			}
		}
	}
	
}

-(void)leaveChannel:(NSString*)channel{
	if(channel){
		if(self->finishedRegistering==YES){
			[self send:[NSString stringWithFormat:@"PART %@",channel]];
		}else{sleep(1);[self leaveChannel:channel];}
	}
}

-(void)msg:(NSString*)msg toChannel:(NSString*)channel{
	if(msg && channel && self->finishedRegistering == YES){
		[self send:[NSString stringWithFormat:@":%@ PRIVMSG %@ :%@",self.nick,channel,msg]];
	}
}

-(void)connect{
    [NSThread detachNewThreadSelector:@selector(establishConnection) toTarget:self withObject:nil];
}
@end
