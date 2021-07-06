//
//  BRMastodonClient.m
//  TweetRain
//
//  Created by b123400 on 2021/06/27.
//

#import "BRMastodonClient.h"
#import "BRMastodonAccount.h"

@implementation BRMastodonClient

+ (instancetype)shared {
    static BRMastodonClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BRMastodonClient alloc] init];
    });
    return instance;
}

- (void)registerAppFor:(NSString*)hostname completionHandler:(void (^)(BRMastodonApp *app, NSError *error))callback {
    if (![hostname hasPrefix:@"http://"] && ![hostname hasPrefix:@"https://"]) {
        hostname = [NSString stringWithFormat:@"https://%@", hostname];
    }
    if ([hostname hasSuffix:@"/"]) {
        hostname = [hostname substringToIndex:hostname.length - 1];
    }
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
        @"redirect_uris": OAUTH_REDIRECT_DEST,
        @"scopes": @"read write",
        @"website": @"https://b123400.net",
    }] dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
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
            @"redirect_uri": OAUTH_REDIRECT_DEST,
            @"grant_type": @"authorization_code",
            @"code": code,
            @"scope": @"read write"
    }] dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
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
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
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
        BRMastodonAccount *account = [[BRMastodonAccount alloc] initWithApp:app
                                                                  accountId:accountId
                                                                        url:result[@"url"]
                                                                oauthResult:oauthResult];
        [account save];
        callback(account, nil);
        
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
            @"redirect_uri": OAUTH_REDIRECT_DEST,
            @"grant_type": @"refresh_token",
            @"refresh_token": refreshToken,
            @"scope": @"read write"
    }] dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
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

- (BRStreamHandler *)streamingStatusesWithAccount:(BRMastodonAccount *)account {
    __block BRStreamHandler *handler = [[BRStreamHandler alloc] init];
    [self accessTokenWithAccount:account
               completionHandler:^(NSString * _Nullable accessToken, NSError * _Nullable error) {
        NSURLComponents *components = [NSURLComponents componentsWithString:account.app.hostName];
        if ([components.scheme isEqual:@"http"]){
            components.scheme = @"ws";
        } else if ([components.scheme isEqual:@"https"]) {
            components.scheme = @"wss";
        }
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"/api/v1/streaming?access_token=%@&stream=user", [accessToken stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]]
                            relativeToURL:components.URL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionWebSocketTask *task = [[NSURLSession sharedSession] webSocketTaskWithRequest:request];
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
            if (![jsonDict[@"event"] isEqualToString:@"update"] || !jsonDict[@"payload"]) {
                return;
            }
            NSDictionary *statusDict = [NSJSONSerialization JSONObjectWithData:[(NSString *)jsonDict[@"payload"] dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options:0
                                                                         error:&jsonError];
            BRMastodonStatus *status = [[BRMastodonStatus alloc] initWithJSONDict:statusDict account:account];
            if (handler.onStatus) {
                handler.onStatus(status);
            }
            
        }];
        [task resume];
    }];
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

- (void)postStatusWithAccount:(BRMastodonAccount *)account
                         text:(NSString *)text
                    inReplyTo:(NSString *)statusId
            completionHandler:(void (^)(BRMastodonStatus * _Nullable status, NSError * _Nullable error))callback {
    NSURL *url = [NSURL URLWithString:@"/api/v1/statuses"
                            relativeToURL:[NSURL URLWithString:account.app.hostName]];
    typeof(self) __weak _self = self;
    [self baseRequestWithURL:url
                     account:account
           completionHandler:^(NSMutableURLRequest * _Nullable request, NSError * _Nullable error) {
        [request setHTTPMethod:@"POST"];
        NSMutableDictionary *params = @{
            @"status": text,
        }.mutableCopy;
        if (statusId) {
            params[@"in_reply_to_id"] = statusId;
        }
        [request setHTTPBody:[[_self httpBodyWithParams: params] dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
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
            callback([[BRMastodonStatus alloc] initWithJSONDict:result account:account], nil);
        }];
        [task resume];
    }];
}

@end
