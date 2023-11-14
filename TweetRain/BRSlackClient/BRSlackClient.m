//
//  BRSlackClient.m
//  TweetRain
//
//  Created by b123400 on 2021/07/11.
//

#import "BRSlackClient.h"
#import "BRSlackChannelSelectionWindowController.h"
#import "BRSlackUser.h"
#import "BRSlackMessage.h"
#import "SettingViewController.h"

@interface BRSlackClient ()  <NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSMapTable *taskToHandleMapping;
@property (nonatomic, strong) NSMutableDictionary<NSString*, BRSlackUser*> *cachedUsers;

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

- (instancetype)init {
    if (self = [super init]) {
        self.taskToHandleMapping = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
        self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                        delegate:self
                                                   delegateQueue:nil];
        self.cachedUsers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)receivedMagicLoginURL:(NSURL *)magicUrl
                   withWindow:(NSWindow *)window
              updatingAccount:(BRSlackAccount * _Nullable)updatingAccount
            completionHandler:(void (^)(BRSlackAccount* account, NSError *error))callback {
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
        NSString *teamURL = [NSString stringWithFormat:@"https://%@.slack.com", tokenResult[@"team"][@"domain"]];
        
        NSURL *url = [NSURL URLWithString:@"https://app.slack.com/auth?app=client&return_to=%2Fclient&teams=&iframe=1"];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        [req setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
        NSURLSessionDataTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                callback(nil, error);
                return;
            }
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"token\":\"([^\"]+)" options:0 error:nil];
            NSString *resBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSArray<NSTextCheckingResult*> *results = [regex matchesInString:resBody options:0 range:NSMakeRange(0, resBody.length)];
            NSString *token = [resBody substringWithRange:[[results firstObject] rangeAtIndex:1]];
            NSLog(@"Token: %@", token);
            
            [_self getChannelListWithToken:token
                                    cursor:nil
                                   cookies:cookies
                         completionHandler:^(NSArray<BRSlackChannel *> *channels, NSError *error) {
                if (error) {
                    callback(nil, error);
                    return;
                }
                if (updatingAccount) {
                    updatingAccount.accountId = userId;
                    updatingAccount.teamId = teamId;
                    updatingAccount.teamName = teamName;
                    updatingAccount.channelIds = updatingAccount.channelIds;
                    updatingAccount.channelNames = updatingAccount.channelNames;
                    updatingAccount.threadId = updatingAccount.threadId;
                    updatingAccount.responseHeaderWithCookies = headersWithCookies;
                    updatingAccount.token = token;
                    [updatingAccount save];
                    callback(updatingAccount, nil);
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    BRSlackChannelSelectionWindowController *controller = [[BRSlackChannelSelectionWindowController alloc] init];
                    controller.channels = channels;
                    [window beginSheet:controller.window completionHandler:^(NSModalResponse returnCode) {
                        if (returnCode == NSModalResponseOK) {
                            BRSlackAccount *account = [[BRSlackAccount alloc] init];
                            account.uuid = [[NSUUID UUID] UUIDString];
                            account.url = [NSURL URLWithString:teamURL];
                            account.accountId = userId;
                            account.teamId = teamId;
                            account.teamName = teamName;
                            account.channelIds = [controller.selectedChannels valueForKeyPath:@"channelId"];
                            account.channelNames = [controller.selectedChannels valueForKeyPath:@"name"];
                            account.threadId = controller.selectedThreadId;
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

- (void)getChannelListWithToken:(NSString  * _Nonnull)token
                         cursor:(NSString  * _Nullable)cursor
                        cookies:(NSArray<NSHTTPCookie*> *)cookies
              completionHandler:(void (^)(NSArray<BRSlackChannel *>* channels, NSError *error))callback {
    NSMutableDictionary *params = @{
        @"token": token,
        @"limit": @"100",
        @"types": @"public_channel,private_channel",
    }.mutableCopy;
    [params setObject:token forKey:@"token"];
    if (cursor) {
        [params setObject:cursor forKey:@"cursor"];
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://slack.com/api/users.conversations?%@", [self queryWithParams:params]]];
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
        if ([resultJSON[@"response_metadata"][@"next_cursor"] isKindOfClass:[NSString class]] && [(NSString *)resultJSON[@"response_metadata"][@"next_cursor"] length]) {
            [self getChannelListWithToken:token
                                   cursor:resultJSON[@"response_metadata"][@"next_cursor"]
                                  cookies:cookies
                        completionHandler:^(NSArray<BRSlackChannel *> *thisChannels, NSError *error) {
                if (error) {
                    callback(nil, error);
                    return;
                }
                callback([channels arrayByAddingObjectsFromArray:thisChannels], nil);
            }];
        } else {
            callback(channels, nil);
        }
    }];
    [task resume];
}

- (void)getChannelListWithAccount:(BRSlackAccount *)account
                completionHandler:(void (^)(NSArray<BRSlackChannel *>* channels, NSError *error))callback {
    NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:account.responseHeaderWithCookies
                                                         forURL:[NSURL URLWithString:@"https://app.slack.com/api/auth.loginMagicBulk"]];
    [self getChannelListWithToken:account.token
                           cursor:nil
                          cookies:cookies
                completionHandler:callback];
}

# pragma mark - Streaming

- (BRSlackStreamHandle *)streamMessageWithAccount:(BRSlackAccount *)account {
    typeof(self) __weak _self = self;
    BRSlackStreamHandle *handle = [[BRSlackStreamHandle alloc] init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"wss://wss-primary.slack.com/?token=%@&gateway_server=%@", account.token, account.teamId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setAllHTTPHeaderFields:[account headersForRequest]];
    NSURLSessionWebSocketTask *task = [self.urlSession webSocketTaskWithRequest:request];
    handle.task = task;
    [self receiveMessageFromWebsocketTask:task
                                onMessage:^(NSURLSessionWebSocketMessage * _Nullable message, NSError * _Nullable error) {
        if (error) {
            if (handle.onError) {
                handle.onError(error);
            }
            return;
        }
        NSData *data = [message data];
        if (!data) {
            data = [[message string] dataUsingEncoding:NSUTF8StringEncoding];
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        {"type":"message","user":"U027Q199PD1","client_msg_id":"018FD003-A387-4AE1-B4EC-93B3C234F465","suppress_notification":false,"text":"Rrrr","team":"T027W17JUFN","blocks":[{"type":"rich_text","block_id":"19NKV","elements":[{"type":"rich_text_section","elements":[{"type":"text","text":"Rrrr"}]}]}],"source_team":"T027W17JUFN","user_team":"T027W17JUFN","channel":"C02793DR8HM","event_ts":"1626268256.000200","ts":"1626268256.000200"}
        
        
//        {"type":"message","user":"U8196FY1W","channel":"CDZTR540M","text":"test","blocks":[{"type":"rich_text","block_id":"b6GCV","elements":[{"type":"rich_text_section","elements":[{"type":"text","text":"test"}]}]}],"client_msg_id":"42f86d6b-97cc-405b-9507-323fa1da2c34","team":"T3R0Y4T24","source_team":"T3R0Y4T24","user_team":"T3R0Y4T24","thread_ts":"1657867942.501739","suppress_notification":false,"event_ts":"1657868823.936069","ts":"1657868823.936069"}
        
        if ([dict[@"type"] isEqualToString:@"message"] &&
            dict[@"subtype"] == nil &&
            (
             [account.channelIds containsObject:dict[@"channel"]] ||
             [[dict[@"thread_ts"] stringByReplacingOccurrencesOfString:@"." withString:@""] isEqual:account.threadId]
            )
        ) {
            [_self messageWithJSONDictionary:dict
                                     account:account
                           completionHandler:^(BRSlackMessage * _Nullable message, NSError * _Nullable error) {
                if (error) {
                    if (handle.onError) {
                        handle.onError(error);
                    }
                    return;
                }
                if (handle.onMessage) {
                    handle.onMessage(message);
                }
            }];

        } else if ([dict[@"type"] isEqualToString:@"error"] && [dict[@"error"][@"code"] isEqualToNumber:@401]) {
            if (handle.onError) {
                NSError *unauthorized = [NSError errorWithDomain:@"BRSlackClient" code:401 userInfo:@{
                    @"account": account,
                }];
                handle.onError(unauthorized);
            }
        }
    }];
    [task resume];
    [self.taskToHandleMapping setObject:handle forKey:task];
    
    [self listEmojiWithAccount:account completionHandler:^(NSDictionary<NSString *,NSString *> * _Nullable emojis, NSError * _Nullable error) {
        if (emojis) {
            [account setEmojiDict:emojis];
        }
    }];
    return handle;
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
    BRSlackStreamHandle *handler = [self.taskToHandleMapping objectForKey:webSocketTask];
    if (!handler) return;
    if (handler.onConnected) {
        handler.onConnected();
    }
}

- (void)URLSession:(NSURLSession *)session
     webSocketTask:(NSURLSessionWebSocketTask *)webSocketTask
  didCloseWithCode:(NSURLSessionWebSocketCloseCode)closeCode
            reason:(NSData *)reason {
    BRSlackStreamHandle *handler = [self.taskToHandleMapping objectForKey:webSocketTask];
    if (!handler) return;
    if (handler.onDisconnected) {
        handler.onDisconnected();
    }
    [self.taskToHandleMapping removeObjectForKey:webSocketTask];
}

# pragma mark - Normal API

- (void)listEmojiWithAccount:(BRSlackAccount *)account
           completionHandler:(void (^)(NSDictionary<NSString *, NSString *> * _Nullable emojis, NSError * _Nullable error))callback {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://slack.com/api/emoji.list?token=%@", account.token]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setAllHTTPHeaderFields:[account headersForRequest]];
    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1 Safari/605.1.15" forHTTPHeaderField:@"User-Agent"];
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
            callback(nil, error);
            return;
        }
        NSError *decodeError = nil;
        NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&decodeError];
        if (![resultJSON isKindOfClass:[NSDictionary class]]) {
            NSLog(@"wrong emoji type %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            callback(nil, [NSError errorWithDomain:NSCocoaErrorDomain
                                              code:0
                                          userInfo:@{
                                              @"response": resultJSON,
                                          }]);
            return;
        }
        callback(resultJSON[@"emoji"], nil);
    }];
    [task resume];
}

- (void)userWithuserId:(NSString *)userId
               account:(BRSlackAccount *)account
     completionHandler:(void (^)(BRSlackUser * _Nullable user, NSError * _Nullable error))callback {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://slack.com/api/users.info?token=%@&user=%@", account.token, userId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setAllHTTPHeaderFields:[account headersForRequest]];
    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1 Safari/605.1.15" forHTTPHeaderField:@"User-Agent"];
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
            callback(nil, error);
            return;
        }
        NSError *decodeError = nil;
        NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&decodeError];
        if (![resultJSON isKindOfClass:[NSDictionary class]]) {
            NSLog(@"wrong emoji type %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            callback(nil, [NSError errorWithDomain:NSCocoaErrorDomain
                                              code:0
                                          userInfo:@{
                                              @"response": resultJSON,
                                          }]);
            return;
        }
        callback([[BRSlackUser alloc] initWithJSONDictionary:resultJSON[@"user"]], nil);
    }];
    [task resume];
}

- (void)cachedUserWithuserId:(NSString *)userId
                     account:(BRSlackAccount *)account
           completionHandler:(void (^)(BRSlackUser * _Nullable user, NSError * _Nullable error))callback {
    if (self.cachedUsers[userId]) {
        callback(self.cachedUsers[userId], nil);
        return;
    }
    typeof(self) __weak _self = self;
    [self userWithuserId:userId
                 account:account
       completionHandler:^(BRSlackUser * _Nullable user, NSError * _Nullable error) {
        [_self.cachedUsers setObject:user forKey:userId];
        callback(user, nil);
    }];
}

- (void)messageWithJSONDictionary:(NSDictionary *)dict
                          account:(BRSlackAccount *)account
                completionHandler:(void (^)(BRSlackMessage * _Nullable message, NSError * _Nullable error))callback {
    NSString *userId = dict[@"user"];
    [self cachedUserWithuserId:userId
                       account:account
             completionHandler:^(BRSlackUser * _Nullable user, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
            // Allow nullable user
        }
        callback([[BRSlackMessage alloc] initWithJSONDict:dict user:user account:account], nil);
    }];
}

- (NSString *)queryWithParams:(NSDictionary<NSString*, NSString*>*) dict {
    NSMutableArray<NSString*> *parts = [NSMutableArray array];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [parts addObject:[NSString stringWithFormat:@"%@=%@", key, [obj stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]]];
    }];
    return [parts componentsJoinedByString:@"&"];
}

@end
