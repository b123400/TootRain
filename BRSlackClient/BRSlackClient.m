//
//  BRSlackClient.m
//  TweetRain
//
//  Created by b123400 on 2021/07/11.
//

#import "BRSlackClient.h"
#import "BRSlackChannel.h"
#import "BRSlackChannelSelectionWindowController.h"
#import "SettingViewController.h"

@interface BRSlackClient ()  <NSURLSessionDelegate>

@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSURLSession *urlSession;

@end

@implementation BRSlackClient

+ (instancetype)shared {
    static BRSlackClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BRSlackClient alloc] init];
    });
    return instance;
}

- (NSURLSession *)urlSession {
    if (_urlSession) {
        return _urlSession;
    }
    _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                delegate:self
                                           delegateQueue:nil];
    return _urlSession;
}

- (void)receivedMagicLoginURL:(NSURL *)magicUrl completionHandler:(void (^)(BRSlackAccount* account, NSError *error))callback {
    typeof(self) __weak _self = self;
    NSString *teamId = magicUrl.host;
    NSString *loginToken = [[magicUrl.path pathComponents] lastObject];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://app.slack.com/api/auth.loginMagicBulk?magic_tokens=z-app-%@-%@&ssb=1", teamId, loginToken]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            callback(nil, error);
            return;
        }
        NSArray<NSHTTPCookie *> *cookies = @[];
        NSDictionary *headersWithCookies = @{};
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
            headersWithCookies = [res allHeaderFields];
            cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headersWithCookies forURL:[req URL]];
        }
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSDictionary *tokenResult = [[jsonDict[@"token_results"] allValues] firstObject];
        NSString *teamName = tokenResult[@"team"][@"name"];
        NSString *teamId = tokenResult[@"team"][@"id"];
        NSString *userId = tokenResult[@"user"];
        
        NSURL *url = [NSURL URLWithString:@"https://app.slack.com/auth?app=client&return_to=%2Fclient&teams=&iframe=1"];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        [req setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
        NSURLSessionDataTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"token\":\"([^\"]+)" options:0 error:nil];
            NSString *resBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSArray<NSTextCheckingResult*> *results = [regex matchesInString:resBody options:0 range:NSMakeRange(0, resBody.length)];
            NSString *token = [resBody substringWithRange:[[results firstObject] rangeAtIndex:1]];
            NSLog(@"Token: %@", token);
            
            [_self getChannelListWithToken:token cookies:cookies completionHandler:^(NSArray<BRSlackChannel *> *channels, NSError *error) {
                if (error) {
                    callback(nil, error);
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    BRSlackChannelSelectionWindowController *controller = [[BRSlackChannelSelectionWindowController alloc] init];
                    controller.channels = channels;
                    [[SettingViewController sharedPrefsWindowController].window beginSheet:controller.window completionHandler:^(NSModalResponse returnCode) {
                        if (returnCode == NSModalResponseOK) {
                            BRSlackAccount *account = [[BRSlackAccount alloc] init];
                            account.accountId = userId;
                            account.teamId = teamId;
                            account.teamName = teamName;
                            account.channelId = controller.selectedChannel.channelId;
                            account.channelName = controller.selectedChannel.name;
                            account.responseHeaderWithCookies = headersWithCookies;
                            account.token = token;
                            [account save];
                            callback(account, nil);
                        } else {
                            callback(nil, nil);
                        }
                    }];
                });
            }];
        }];
        [task resume];
    }];
    [task resume];
}

- (void)getChannelListWithToken:(NSString *)token cookies:(NSArray<NSHTTPCookie*> *)cookies completionHandler:(void (^)(NSArray<BRSlackChannel *>* channels, NSError *error))callback {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://slack.com/api/conversations.list?token=%@", token]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
            callback(nil, error);
            return;
        }
        NSError *decodeError = nil;
        NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&decodeError];
        if (![resultJSON isKindOfClass:[NSDictionary class]]) {
            NSLog(@"wrong type %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            callback(nil, [NSError errorWithDomain:NSCocoaErrorDomain
                                              code:0
                                          userInfo:@{
                                              @"response": resultJSON,
                                          }]);
            return;
        }
        NSMutableArray<BRSlackChannel *> *channels = [NSMutableArray array];
        for (NSDictionary *dict in resultJSON[@"channels"]) {
            [channels addObject:[[BRSlackChannel alloc] initWithAPIJSON:dict]];
        }
        callback(channels, nil);
    }];
    [task resume];
}

- (BRSlackStreamHandler *)streamMessageWithAccount:(BRSlackAccount *)account {
    BRSlackStreamHandler *handler = [[BRSlackStreamHandler alloc] init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"wss://wss-primary.slack.com/?token=%@&gateway_server=%@", account.token, account.teamId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setAllHTTPHeaderFields:[account headersForRequest]];
    NSURLSessionWebSocketTask *task = [self.urlSession webSocketTaskWithRequest:request];
    handler.task = task;
    [self receiveMessageFromWebsocketTask:task
                                onMessage:^(NSURLSessionWebSocketMessage * _Nullable message, NSError * _Nullable error) {
        NSData *data = [message data];
        if (!data) {
            data = [[message string] dataUsingEncoding:NSUTF8StringEncoding];
        }
        NSLog(@"fuck %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"fuck error %@", error);
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        {"type":"message","user":"U027Q199PD1","client_msg_id":"018FD003-A387-4AE1-B4EC-93B3C234F465","suppress_notification":false,"text":"Rrrr","team":"T027W17JUFN","blocks":[{"type":"rich_text","block_id":"19NKV","elements":[{"type":"rich_text_section","elements":[{"type":"text","text":"Rrrr"}]}]}],"source_team":"T027W17JUFN","user_team":"T027W17JUFN","channel":"C02793DR8HM","event_ts":"1626268256.000200","ts":"1626268256.000200"}
        if ([dict[@"type"] isEqualToString:@"message"] && [dict[@"channel"] isEqualToString:account.channelId]) {
            if (handler.onMessage) {
                handler.onMessage(dict[@"text"]);
            }
        }
    }];
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
    NSLog(@"open");
}

- (void)URLSession:(NSURLSession *)session
     webSocketTask:(NSURLSessionWebSocketTask *)webSocketTask
  didCloseWithCode:(NSURLSessionWebSocketCloseCode)closeCode
            reason:(NSData *)reason {
    NSLog(@"close %ld, %@", closeCode, [[NSString alloc] initWithData:reason encoding:NSUTF8StringEncoding]);
}

- (instancetype)setupWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret {
    self.clientId = clientId;
    self.clientSecret = clientSecret;
    return self;
}

- (NSString *)httpBodyWithParams:(NSDictionary<NSString*, NSString*>*) dict {
    NSMutableArray<NSString*> *parts = [NSMutableArray array];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [parts addObject:[NSString stringWithFormat:@"%@=%@", key, [obj stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]]];
    }];
    return [parts componentsJoinedByString:@"&"];
}

@end
