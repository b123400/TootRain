//
//  BRMisskeyClient.m
//  TweetRain
//
//  Created by b123400 on 2022/12/22.
//

#import "BRMisskeyClient.h"
#import "BRMisskeyUser.h"

@interface BRMisskeyClient ()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSMapTable *taskToHandleMapping;

@end

@implementation BRMisskeyClient

+ (instancetype)shared {
    static BRMisskeyClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BRMisskeyClient alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.taskToHandleMapping = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
        self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                        delegate:self
                                                   delegateQueue:nil];
    }
    return self;
}

- (NSURL *)authURLWithHost:(NSURL *)host {
    NSURLComponents *components = [NSURLComponents componentsWithURL:host resolvingAgainstBaseURL:NO];
    NSString *session = [[NSUUID UUID] UUIDString];
    [components setPath:[NSString stringWithFormat:@"/miauth/%@", session]];
    NSMutableArray *queryItems = [NSMutableArray array];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"name" value:@"TootRain"]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"icon" value:@"https://b123400.net/tootrain/mac.png"]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"callback" value:MISSKEY_OAUTH_REDIRECT_DEST]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"permission" value:@"write:notes,write:favorites,write:reactions"]];
    [components setQueryItems:queryItems];
    return [components URL];
}

- (void)newAccountWithHost:(NSURL *)host
                 sessionId:(NSString *)sessionId
         completionHandler:(void (^_Nonnull)(BRMisskeyAccount * _Nullable account, NSError * _Nullable error))callback {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"/api/miauth/%@/check", sessionId]
                            relativeToURL:host];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request
                                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error);
            callback(nil, error);
            return;
        }
        NSLog(@"str %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSError *decodeError = nil;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&decodeError];
        if (![result isKindOfClass:[NSDictionary class]] || decodeError != nil) {
            NSLog(@"Decode error: %@", decodeError);
            callback(nil, decodeError);
            return;
        }
        if (result[@"error"]) {
            callback(nil,
                     [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:0
                                     userInfo:@{@"response": result}]);
            return;
        }
        NSString *accessToken = result[@"token"];
        BRMisskeyUser *user = [[BRMisskeyUser alloc] initWithJSONDictionary:result[@"user"]];
        BRMisskeyAccount *account = [[BRMisskeyAccount alloc] initNewAccountWithHostName:host.absoluteString
                                                                             accessToken:accessToken
                                                                                    user:user];
        [account save];
        callback(account, error);
    }];
    [task resume];
}

# pragma mark: - Stream

- (BRMisskeyStreamHandle *)streamStatusWithAccount:(BRMisskeyAccount *)account {
    NSURLComponents *components = [NSURLComponents componentsWithString:account.hostName];
    [components setPath:@"/streaming"];
    if ([components.scheme isEqual:@"http"]){
        components.scheme = @"ws";
    } else if ([components.scheme isEqual:@"https"]) {
        components.scheme = @"wss";
    }
    NSMutableArray<NSURLQueryItem*> *queryItems = [NSMutableArray array];
    [queryItems addObject:[[NSURLQueryItem alloc] initWithName:@"i" value:account.accessToken]];
    [components setQueryItems:queryItems];
    
    BRMisskeyStreamHandle *handler = [[BRMisskeyStreamHandle alloc] init];
    NSURLRequest *request = [NSURLRequest requestWithURL:components.URL];
    NSURLSessionWebSocketTask *task = [self.urlSession webSocketTaskWithRequest:request];
    handler.task = task;
    [self receiveMessageFromWebsocketTask:task
                                onMessage:^(NSURLSessionWebSocketMessage * _Nullable message, NSError * _Nullable error) {
        NSLog(@"ws str: %@, error: %@", [message string], error);
        if (error) {
            if (handler.onError != nil) {
                handler.onError(error);
            }
            return;
        }
        NSError *jsonError = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[message.string dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options:0
                                                                   error:&jsonError];
        if (jsonError) {
            if (handler.onError != nil) {
                handler.onError(jsonError);
            }
            return;
        }
        if (![jsonDict isKindOfClass:[NSDictionary class]]) {
            if (handler.onError != nil) {
                handler.onError([NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{
                    @"message": @"Not a dict",
                    @"value": jsonDict,
                }]);
            }
            return;
        }
        if ([jsonDict[@"type"] isEqualTo:@"channel"] && [jsonDict[@"body"] isKindOfClass:[NSDictionary class]] && handler.onStatus) {
            NSDictionary *eventDict = jsonDict[@"body"];
            NSString *eventType = eventDict[@"type"];
            if ([eventType isEqualTo:@"note"] || [eventType isEqualTo:@"reply"] || [eventType isEqualTo:@"mention"]) {
                BRMisskeyStatus *status = [[BRMisskeyStatus alloc] initWithJSONDictionary:eventDict[@"body"]];
                handler.onStatus(status);
            }
        }
    }];
    [self.taskToHandleMapping setObject:handler forKey:task];
    [task resume];
    return handler;
}

- (void)receiveMessageFromWebsocketTask:(NSURLSessionWebSocketTask *)task
onMessage:(void (^)(NSURLSessionWebSocketMessage * _Nullable message, NSError * _Nullable error))onMessage {
    typeof(self) __weak _self = self;
    [task receiveMessageWithCompletionHandler:^(NSURLSessionWebSocketMessage * _Nullable message, NSError * _Nullable error) {
        onMessage(message, error);
        if (!error) {
            [_self receiveMessageFromWebsocketTask:task
                                         onMessage:onMessage];
        }
    }];
}

- (void)URLSession:(NSURLSession *)session
     webSocketTask:(NSURLSessionWebSocketTask *)webSocketTask
didOpenWithProtocol:(NSString *)protocol {
    NSLog(@"did open");
    NSDictionary *connectMessage = @{
        @"type": @"connect",
        @"body": @{
            @"channel": @"localTimeline",
            @"id": @"foobar"
        }
    };
    NSData *d = [NSJSONSerialization dataWithJSONObject:connectMessage options:0 error:nil];
    NSString *encoded = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSURLSessionWebSocketMessage *strmsg = [[NSURLSessionWebSocketMessage alloc] initWithString:encoded];
    [webSocketTask sendMessage:strmsg completionHandler:^(NSError * _Nullable error) {
        NSLog(@"sent message %@", error);
    }];
    BRMisskeyStreamHandle *handler = [self.taskToHandleMapping objectForKey:webSocketTask];
    if (!handler) return;
    if (handler.onConnected) {
        handler.onConnected();
    }
}

- (void)URLSession:(NSURLSession *)session
     webSocketTask:(NSURLSessionWebSocketTask *)webSocketTask
  didCloseWithCode:(NSURLSessionWebSocketCloseCode)closeCode
            reason:(NSData *)reason {
    NSLog(@"did close");
    BRMisskeyStreamHandle *handler = [self.taskToHandleMapping objectForKey:webSocketTask];
    if (!handler) return;
    if (handler.onDisconnected) {
        handler.onDisconnected();
    }
    [self.taskToHandleMapping removeObjectForKey:webSocketTask];
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    NSLog(@"didBecomeInvalidWithError");
}

@end
