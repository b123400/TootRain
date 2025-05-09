//
//  BRMastodonClient.m
//  TweetRain
//
//  Created by b123400 on 2021/06/27.
//

#import "BRMastodonClient.h"
#import "BRMastodonAccount.h"

@interface BRMastodonClient () <NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSMapTable *taskToHandleMapping;

@end

@implementation BRMastodonClient

+ (instancetype)shared {
    static BRMastodonClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BRMastodonClient alloc] init];
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

- (void)registerAppFor:(NSString*)hostname completionHandler:(void (^)(BRMastodonApp *app, NSError *error))callback {
    BRMastodonApp *existingApp = [BRMastodonApp appWithHostname:hostname];
    if (existingApp != nil) {
        callback(existingApp, nil);
        return;
    }
    
    NSURL *endpoint = [NSURL URLWithString:@"/api/v1/apps" relativeToURL:[NSURL URLWithString:hostname]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:endpoint];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[self httpBodyWithParams: @{
        @"client_name": @"Tootrain",
        @"redirect_uris": MASTODON_OAUTH_REDIRECT_DEST,
        @"scopes": @"read write",
        @"website": @"https://b123400.net",
    }] dataUsingEncoding:NSUTF8StringEncoding]];
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
            NSError *responseError = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{@"response": result}];
            NSLog(@"responseError: %@", responseError);
            callback(nil, responseError);
            return;
        }
        BRMastodonApp *app  = [[BRMastodonApp alloc] initWithHostName:hostname
                                                             clientId:result[@"client_id"]
                                                         clientSecret:result[@"client_secret"]
                               ];
        [app save];
        callback(app, error);
    }];
    [task resume];
}

- (void)getAccessTokenWithApp:(BRMastodonApp *)app
                         code:(NSString *)code
            completionHandler:(void (^)(BRMastodonOAuthResult * _Nullable result, NSError * _Nullable error))callback {
    NSURL *url = [NSURL URLWithString:@"/oauth/token"
                            relativeToURL:[NSURL URLWithString:app.hostName]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[ [self httpBodyWithParams:@{
            @"client_id": app.clientId,
            @"client_secret": app.clientSecret,
            @"redirect_uri": MASTODON_OAUTH_REDIRECT_DEST,
            @"grant_type": @"authorization_code",
            @"code": code,
            @"scope": @"read write"
    }] dataUsingEncoding:NSUTF8StringEncoding]];
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
        BRMastodonOAuthResult *oauthResult = [[BRMastodonOAuthResult alloc] init];
        oauthResult.accessToken = result[@"access_token"];
        oauthResult.refreshToken = result[@"refresh_token"];
        oauthResult.expiresIn = result[@"expires_in"];
        callback(oauthResult, error);
    }];
    [task resume];
}

- (NSString *)httpBodyWithParams:(NSDictionary<NSString*, NSString*>*) dict {
    NSMutableArray<NSString*> *parts = [NSMutableArray array];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [parts addObject:[NSString stringWithFormat:@"%@=%@", key, [obj stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]]];
    }];
    return [parts componentsJoinedByString:@"&"];
}

- (void) verifyAccountWithApp:(BRMastodonApp *)app
                  oauthResult:(BRMastodonOAuthResult *)oauthResult
            completionHandler:(void (^)(BRMastodonAccount *account, NSError *error))callback {
    NSURL *url = [NSURL URLWithString:@"/api/v1/accounts/verify_credentials"
                            relativeToURL:[NSURL URLWithString:app.hostName]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", oauthResult.accessToken] forHTTPHeaderField:@"Authorization"];
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
            callback(nil, [NSError errorWithDomain:NSCocoaErrorDomain
                                              code:0
                                          userInfo:@{
                                              @"response": result,
                            }]);
            return;
        }
        NSString *accountId = result[@"id"];
        BRMastodonAccount *existingAccount = [BRMastodonAccount accountWithApp:app accountId:accountId];
        if (existingAccount) {
            // Update existing account's cred
            [existingAccount renew:oauthResult];
            callback(existingAccount, nil);
            return;
        }
        NSURLComponents *components = [NSURLComponents componentsWithString:result[@"url"]];
        NSString *accountDisplayName = [NSString stringWithFormat:@"@%@@%@", result[@"acct"], components.host];
        BRMastodonAccount *account = [[BRMastodonAccount alloc] initWithApp:app
                                                                  accountId:accountId
                                                                        url:result[@"url"]
                                                                displayName:accountDisplayName
                                                                oauthResult:oauthResult];
        [self getInstanceInfoWithApp:app
                   completionHandler:^(BRMastodonInstanceInfo * _Nullable result, NSError * _Nullable error) {
            if (!error && result) {
                account.software = result.software;
            } else {
                // Ignore error, isPleroma isn't that important
            }
            [account save];
            callback(account, nil);
        }];
    }];
    [task resume];
}

- (void)refreshAccessTokenWithApp:(BRMastodonApp *)app
                     refreshToken:(NSString *)refreshToken
                completionHandler:(void (^)(BRMastodonOAuthResult * _Nullable result, NSError * _Nullable error))callback {
    NSURL *url = [NSURL URLWithString:@"/oauth/token"
                            relativeToURL:[NSURL URLWithString:app.hostName]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[ [self httpBodyWithParams:@{
            @"client_id": app.clientId,
            @"client_secret": app.clientSecret,
            @"redirect_uri": MASTODON_OAUTH_REDIRECT_DEST,
            @"grant_type": @"refresh_token",
            @"refresh_token": refreshToken ?: @"",
            @"scope": @"read write"
    }] dataUsingEncoding:NSUTF8StringEncoding]];
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
        BRMastodonOAuthResult *oauthResult = [[BRMastodonOAuthResult alloc] init];
        oauthResult.accessToken = result[@"access_token"];
        oauthResult.refreshToken = result[@"refresh_token"];
        oauthResult.expiresIn = result[@"expires_in"];
        callback(oauthResult, error);
    }];
    [task resume];
}

- (void)accessTokenWithAccount:(BRMastodonAccount *)account
             completionHandler:(void (^)(NSString * _Nullable accessToken, NSError * _Nullable error))callback {
    if ([[account expires] timeIntervalSinceDate:[NSDate date]] > 0) {
        callback(account.accessToken, nil);
        return;
    }
    [self refreshAccessTokenWithApp:[account app]
                       refreshToken:[account refreshToken]
                  completionHandler:^(BRMastodonOAuthResult * _Nonnull result, NSError * _Nonnull error) {
        if (error) {
            callback(nil, error);
            return;
        }
        [account renew:result];
        callback(result.accessToken, nil);
    }];
}

- (void)baseRequestWithURL:(NSURL *)url
                   account:(BRMastodonAccount *)account
         completionHandler:(void (^)(NSMutableURLRequest * _Nullable request, NSError * _Nullable error))callback {
    typeof(self) __weak _self = self;
    [self accessTokenWithAccount:account
               completionHandler:^(NSString * _Nullable accessToken, NSError * _Nullable error) {
        if (error) {
            callback(nil, error);
            return;
        }
        callback([_self requestWithURL:url accessToken:accessToken], nil);
    }];
}

- (NSMutableURLRequest *)requestWithURL:(NSURL*)url accessToken:(NSString *)accessToken {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
    return request;
}

- (void)getInstanceInfoWithApp:(BRMastodonApp *)app
             completionHandler:(void (^) (BRMastodonInstanceInfo * _Nullable result, NSError * _Nullable error))callback {
    NSURL *endpoint = [NSURL URLWithString:@"/api/v1/instance" relativeToURL:[NSURL URLWithString:app.hostName]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:endpoint];
    [request setHTTPMethod:@"GET"];
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
            NSError *responseError = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{@"response": result}];
            NSLog(@"responseError: %@", responseError);
            callback(nil, responseError);
            return;
        }
        BRMastodonInstanceInfo *info = [[BRMastodonInstanceInfo alloc] initWithJSONDictionary:result];
        callback(info, error);
    }];
    [task resume];
}

- (BRMastodonStreamHandle *)streamingStatusesWithAccount:(BRMastodonAccount *)account {
    BRMastodonStreamSource source = account.source;
    __block BRMastodonStreamHandle *handler = [[BRMastodonStreamHandle alloc] init];
    typeof(self) __weak _self = self;
    [self accessTokenWithAccount:account
               completionHandler:^(NSString * _Nullable accessToken, NSError * _Nullable error) {
        NSURLComponents *components = [NSURLComponents componentsWithString:account.app.hostName];
        if ([components.scheme isEqual:@"http"]){
            components.scheme = @"ws";
        } else if ([components.scheme isEqual:@"https"]) {
            components.scheme = @"wss";
        }
        NSMutableArray<NSURLQueryItem*> *queryItems = [NSMutableArray array];
        [queryItems addObject:[[NSURLQueryItem alloc] initWithName:@"access_token" value:accessToken]];
        [queryItems addObject:[[NSURLQueryItem alloc] initWithName:@"stream" value:[self queryParameterForStreamSource:source]]];
        
        if ((source == BRMastodonStreamSourceHashtag || source == BRMastodonStreamSourceHashtagLocal) && account.sourceHashtag.length) {
            [queryItems addObject:[[NSURLQueryItem alloc] initWithName:@"tag" value:account.sourceHashtag]];
        } else if (source == BRMastodonStreamSourceList && account.sourceListId.length) {
            [queryItems addObject:[[NSURLQueryItem alloc] initWithName:@"list" value:account.sourceListId]];
        }
        [components setQueryItems:queryItems];
        [components setPath:@"/api/v1/streaming"];
        
        NSURL *url = components.URL;
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionWebSocketTask *task = [_self.urlSession webSocketTaskWithRequest:request];
        [_self receiveMessageFromWebsocketTask:task
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
            NSDictionary *statusDict = [self findStatusDictionaryFromStreamEvent: jsonDict];
            if (!statusDict) return;
            BRMastodonStatus *status = [[BRMastodonStatus alloc] initWithJSONDict:statusDict account:account];
            if (handler.onStatus) {
                handler.onStatus(status);
            }
            
        }];
        handler.task = task;
        NSTimer * __block pingTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                             repeats:YES
                                                               block:^(NSTimer * _Nonnull timer) {
            if (task.closeCode == NSURLSessionWebSocketCloseCodeInvalid) {
                [task sendPingWithPongReceiveHandler:^(NSError * _Nullable error) {
                    if (error) {
                        [pingTimer invalidate];
                        pingTimer = nil;
                    }
                }];
            } else {
                [pingTimer invalidate];
                pingTimer = nil;
            }
        }];
        [_self.taskToHandleMapping setObject:handler forKey:task];
        [task resume];
    }];
    return handler;
}

- (NSDictionary *)findStatusDictionaryFromStreamEvent:(NSDictionary*)jsonDict {
    NSString *eventStr = jsonDict[@"event"];
    NSString *payloadStr = jsonDict[@"payload"];
    if (!eventStr || !payloadStr) return nil;
    NSDictionary *payloadDict = [NSJSONSerialization JSONObjectWithData:[(NSString *)payloadStr dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:0
                                                                  error:nil];
    if (!payloadDict) return nil;
    if ([eventStr isEqualToString:@"update"]) {
        return payloadDict;
    }
    if ([eventStr isEqualTo:@"notification"]) {
        if ([payloadDict[@"type"] isEqualTo:@"status"] || [payloadDict[@"type"] isEqualTo:@"mention"]) {
            return payloadDict[@"status"];
        }
    }
    if ([eventStr isEqualTo:@"conversation"]) {
        return payloadDict[@"last_status"];
    }
    return nil;
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

- (void)replyToStatus:(BRMastodonStatus *)status
             withText:(NSString *)text
    completionHandler:(void (^)(BRMastodonStatus * _Nullable status, NSError * _Nullable error))callback {
    NSURL *url = [NSURL URLWithString:@"/api/v1/statuses"
                        relativeToURL:[NSURL URLWithString:status.account.app.hostName]];
    typeof(self) __weak _self = self;
    [self baseRequestWithURL:url
                     account:status.account
           completionHandler:^(NSMutableURLRequest * _Nullable request, NSError * _Nullable error) {
        [request setHTTPMethod:@"POST"];
        NSMutableDictionary *params = @{
            @"status": text,
        }.mutableCopy;
        if (status.statusID) {
            params[@"in_reply_to_id"] = status.statusID;
        }
        [request setHTTPBody:[[_self httpBodyWithParams: params] dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLSessionDataTask *task = [_self.urlSession dataTaskWithRequest:request
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
            callback([[BRMastodonStatus alloc] initWithJSONDict:result account:status.account], nil);
        }];
        [task resume];
    }];
}

- (void)bookmarkStatus:(BRMastodonStatus *)status
     completionHandler:(void (^)(NSError * _Nullable error))callback {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"/api/v1/statuses/%@/bookmark", status.statusID]
                        relativeToURL:[NSURL URLWithString:status.account.app.hostName]];
    typeof(self) __weak _self = self;
    [self baseRequestWithURL:url
                     account:status.account
           completionHandler:^(NSMutableURLRequest * _Nullable request, NSError * _Nullable error) {
        [request setHTTPMethod:@"POST"];
        NSURLSessionDataTask *task = [_self.urlSession dataTaskWithRequest:request
                                                         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error: %@", error);
                callback(error);
                return;
            }
            NSLog(@"str %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSError *decodeError = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&decodeError];
            if (![result isKindOfClass:[NSDictionary class]] || decodeError != nil) {
                NSLog(@"Decode error: %@", decodeError);
                callback(decodeError);
                return;
            }
            if (result[@"error"]) {
                callback([NSError errorWithDomain:NSCocoaErrorDomain
                                             code:0
                                         userInfo:@{@"response": result}]);
                return;
            }
            status.bookmarked = YES;
            callback(nil);
        }];
        [task resume];
    }];
}

- (void)favouriteStatus:(BRMastodonStatus *)status
      completionHandler:(void (^)(NSError * _Nullable error))callback {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"/api/v1/statuses/%@/favourite", status.statusID]
                        relativeToURL:[NSURL URLWithString:status.account.app.hostName]];
    typeof(self) __weak _self = self;
    [self baseRequestWithURL:url
                     account:status.account
           completionHandler:^(NSMutableURLRequest * _Nullable request, NSError * _Nullable error) {
        [request setHTTPMethod:@"POST"];
        NSURLSessionDataTask *task = [_self.urlSession dataTaskWithRequest:request
                                                         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error: %@", error);
                callback(error);
                return;
            }
            NSLog(@"str %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSError *decodeError = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&decodeError];
            if (![result isKindOfClass:[NSDictionary class]] || decodeError != nil) {
                NSLog(@"Decode error: %@", decodeError);
                callback(decodeError);
                return;
            }
            if (result[@"error"]) {
                callback([NSError errorWithDomain:NSCocoaErrorDomain
                                             code:0
                                         userInfo:@{@"response": result}]);
                return;
            }
            status.favourited = YES;
            callback(nil);
        }];
        [task resume];
    }];
}

- (void)reblogStatus:(BRMastodonStatus *)status
   completionHandler:(void (^)(NSError * _Nullable error))callback {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"/api/v1/statuses/%@/reblog", status.statusID]
                        relativeToURL:[NSURL URLWithString:status.account.app.hostName]];
    typeof(self) __weak _self = self;
    [self baseRequestWithURL:url
                     account:status.account
           completionHandler:^(NSMutableURLRequest * _Nullable request, NSError * _Nullable error) {
        [request setHTTPMethod:@"POST"];
        NSURLSessionDataTask *task = [_self.urlSession dataTaskWithRequest:request
                                                         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error: %@", error);
                callback(error);
                return;
            }
            NSLog(@"str %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSError *decodeError = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&decodeError];
            if (![result isKindOfClass:[NSDictionary class]] || decodeError != nil) {
                NSLog(@"Decode error: %@", decodeError);
                callback(decodeError);
                return;
            }
            if (result[@"error"]) {
                callback([NSError errorWithDomain:NSCocoaErrorDomain
                                             code:0
                                         userInfo:@{@"response": result}]);
                return;
            }
            status.favourited = YES;
            callback(nil);
        }];
        [task resume];
    }];
}

- (void)getListsWithAccount:(BRMastodonAccount *)account
          completionHandler:(void (^)(NSArray<BRMastodonList *> * _Nullable lists, NSError * _Nullable error))callback {
    NSURL *url = [NSURL URLWithString:@"/api/v1/lists"
                        relativeToURL:[NSURL URLWithString:account.app.hostName]];
    typeof(self) __weak _self = self;
    [self baseRequestWithURL:url
                     account:account
           completionHandler:^(NSMutableURLRequest * _Nullable request, NSError * _Nullable error) {
        [request setHTTPMethod:@"GET"];
        NSURLSessionDataTask *task = [_self.urlSession dataTaskWithRequest:request
                                                         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error: %@", error);
                callback(nil, error);
                return;
            }
            NSLog(@"str %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSError *decodeError = nil;
            NSArray *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&decodeError];
            if ([result isKindOfClass:[NSDictionary class]] && ((NSDictionary*)result)[@"error"]) {
                callback(nil, [NSError errorWithDomain:NSCocoaErrorDomain
                                                  code:0
                                              userInfo:@{@"response": result}]);
                return;
            }
            if (![result isKindOfClass:[NSArray class]] || decodeError != nil) {
                NSLog(@"Decode error: %@", decodeError);
                callback(nil, decodeError);
                return;
            }

            NSMutableArray *lists = [NSMutableArray arrayWithCapacity:result.count];
            for (NSDictionary *dict in result) {
                [lists addObject:[[BRMastodonList alloc] initWithJSONDictionary:dict]];
            }
            callback(lists, nil);
        }];
        [task resume];
    }];
}

#pragma mark - Delegate

- (void)URLSession:(NSURLSession *)session
     webSocketTask:(NSURLSessionWebSocketTask *)webSocketTask
didOpenWithProtocol:(NSString *)protocol {
    BRMastodonStreamHandle *handler = [self.taskToHandleMapping objectForKey:webSocketTask];
    if (!handler) return;
    if (handler.onConnected) {
        handler.onConnected();
    }
}

- (void)URLSession:(NSURLSession *)session
     webSocketTask:(NSURLSessionWebSocketTask *)webSocketTask
  didCloseWithCode:(NSURLSessionWebSocketCloseCode)closeCode
            reason:(NSData *)reason {
    BRMastodonStreamHandle *handler = [self.taskToHandleMapping objectForKey:webSocketTask];
    NSString *reasonStr = [[NSString alloc] initWithData:reason encoding:NSUTF8StringEncoding];
    NSLog(@"reason %@", reasonStr);
    if (!handler) return;

    if (handler.onDisconnected) {
        handler.onDisconnected();
    }
    [self.taskToHandleMapping removeObjectForKey:webSocketTask];
}

- (NSString *)queryParameterForStreamSource:(BRMastodonStreamSource)source {
    switch (source) {
        case BRMastodonStreamSourceUser:
            return @"user";
        case BRMastodonStreamSourceUserNotification:
            return @"user:notification";
        case BRMastodonStreamSourceList:
            return @"list";
        case BRMastodonStreamSourceDirect:
            return @"direct";
        case BRMastodonStreamSourceHashtag:
            return @"hashtag";
        case BRMastodonStreamSourceHashtagLocal:
            return @"hashtag:local";
        case BRMastodonStreamSourcePublic:
            return @"public";
        case BRMastodonStreamSourcePublicLocal:
            return @"public:local";
        case BRMastodonStreamSourcePublicRemote:
            return @"public:remote";
        default:
            break;
    }
    return nil;
}

+ (NSAttributedString *)attributedString:(NSString *)string withEmojisReplaced:(NSArray<BRMastodonEmoji*> *)emojis {
    NSMutableString *text = [string mutableCopy];
    for (BRMastodonEmoji *emoji in emojis) {
        [text replaceOccurrencesOfString:[NSString stringWithFormat:@":%@:", emoji.shortcode]
                              withString:[NSString stringWithFormat:@"<img src=\"%@\">", emoji.URL]
                                 options:NSCaseInsensitiveSearch
                                   range:NSMakeRange(0, text.length)];
    }
    
    NSDictionary *options = @{
        NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
        NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)
    };
    return [[NSAttributedString alloc] initWithHTML:[text dataUsingEncoding:NSUTF8StringEncoding]
                                            options:options
                                 documentAttributes:nil];
}

@end
