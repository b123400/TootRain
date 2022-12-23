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
@property (nonatomic, strong) NSURLSessionWebSocketTask *task;

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

- (void)startStream {
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
            @"channel": @"homeTimeline",
            @"id": @"foobar"
        }
    };
//        {"type": "connect","body": {"channel": "globalTimeline", "id": "foobar"}}
    
    NSData *d = [NSJSONSerialization dataWithJSONObject:connectMessage options:0 error:nil];
    NSURLSessionWebSocketMessage *message = [[NSURLSessionWebSocketMessage alloc] initWithData:d];
    NSString *encoded = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSURLSessionWebSocketMessage *strmsg = [[NSURLSessionWebSocketMessage alloc] initWithString:encoded];
    [webSocketTask sendMessage:strmsg completionHandler:^(NSError * _Nullable error) {
        NSLog(@"sent message %@", error);
    }];
//    BRMastodonStreamHandle *handler = [self.taskToHandleMapping objectForKey:webSocketTask];
//    if (!handler) return;
//    if (handler.onConnected) {
//        handler.onConnected();
//    }
}

- (void)URLSession:(NSURLSession *)session
     webSocketTask:(NSURLSessionWebSocketTask *)webSocketTask
  didCloseWithCode:(NSURLSessionWebSocketCloseCode)closeCode
            reason:(NSData *)reason {
    NSLog(@"did close");
//    BRMastodonStreamHandle *handler = [self.taskToHandleMapping objectForKey:webSocketTask];
//    if (!handler) return;
//    if (handler.onDisconnected) {
//        handler.onDisconnected();
//    }
//    [self.taskToHandleMapping removeObjectForKey:webSocketTask];
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    NSLog(@"didBecomeInvalidWithError");
}

@end
