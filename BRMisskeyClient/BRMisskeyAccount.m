//
//  BRMisskeyAccount.m
//  TweetRain
//
//  Created by b123400 on 2022/12/23.
//

#import "BRMisskeyAccount.h"

@implementation BRMisskeyAccount

+ (NSArray<BRMisskeyAccount*> *)allAccounts {
    NSMutableArray *result = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *servers = (NSDictionary*)[defaults objectForKey:@"BRMisskeyAccount"];
    if (!servers) {
        return result;
    }
    for (NSString *host in servers) {
        NSDictionary *server = servers[host];
        for (NSString *accountId in server) {
            BRMisskeyAccount *account = [BRMisskeyAccount accountWithHostName:host accountId:accountId];
            if (!account) continue;
            [result addObject:account];
        }
    }
    return result;
}

+ (instancetype)accountWithHostName:(NSString *)hostName accountId:(NSString *)accountId {
    if (!hostName) return nil;
    
    // Access token
    NSDictionary *dict = @{
        (id)kSecClass: (id)kSecClassInternetPassword,
        (id)kSecAttrServer: hostName,
        (id)kSecReturnAttributes: (id)kCFBooleanTrue,
        (id)kSecAttrType: [NSNumber numberWithUnsignedInt:'otok'],
        (id)kSecAttrAccount: accountId,
        (id)kSecReturnData: (id)kCFBooleanTrue
    };

    // Look up server in the keychain
    NSDictionary *found = nil;
    CFDictionaryRef foundCF;
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef) dict, (CFTypeRef*)&foundCF);

    // Check if found
    found = (__bridge NSDictionary*)(foundCF);
    if (!found)
        return nil;

    // Found
    NSString *accessToken = [[NSString alloc] initWithData:found[(id)kSecValueData] encoding:NSUTF8StringEncoding];

    // Found
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *servers = (NSDictionary*)[defaults objectForKey:@"BRMisskeyAccount"];
    NSDictionary *accounts = (NSDictionary*)servers[hostName];
    NSString *host = accounts[accountId][@"host"];
    if (!host) {
        return nil;
    }
    return [[BRMisskeyAccount alloc] initWithHostName:(NSString *)hostName
                                            accountId:accountId
                                          accessToken:accessToken
                                           dictionary:accounts[accountId]
    ];
}

- (instancetype)initWithHostName:(NSString *)hostName
                       accountId:(NSString *)accountId
                     accessToken:accessToken
                      dictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.hostName = hostName;
        self.accountId = accountId;
        self.accessToken = accessToken;
//        self.url = dict[@"url"];
        self.displayName = dict[@"displayName"];
//        self.expires = dict[@"expires"];
//        self.source = [BRMastodonAccount sourceWithStringRepresentation:dict[@"source"]];
//        self.sourceHashtag = dict[@"hashtag"] ?: @"";
//        self.sourceListId = dict[@"listId"] ?: @"";
//        self.sourceListName = dict[@"listName"] ?: @"";
    }
    return self;
}

- (instancetype)initNewAccountWithHostName:(NSString *)hostName
                               accessToken:(NSString *)accessToken
                                      user:(BRMisskeyUser *)user {
    if (self = [super init]) {
        self.hostName = hostName;
        self.accessToken = accessToken;
        self.accountId = user.userID;
        self.displayName = user.displayName;
    }
    return self;
}

//- (instancetype)initWithApp:(BRMastodonApp *)app
//                  accountId:(NSString *)accountId
//                        url:(NSString *)url
//                displayName:(NSString *)displayName
//                oauthResult:(BRMastodonOAuthResult *)oauthResult {
//    if (self = [super init]) {
//        self.app = app;
//        self.accountId = accountId;
//        self.url = url;
//        self.displayName = displayName;
//        self.accessToken = oauthResult.accessToken;
//        self.refreshToken = oauthResult.refreshToken;
//        self.expires = oauthResult.expiresIn == nil
//            ? [NSDate dateWithTimeIntervalSince1970:4765132800] // 2099: ~ never expire
//            : [[NSDate date] dateByAddingTimeInterval:[oauthResult.expiresIn doubleValue]];
//        self.source = BRMastodonStreamSourceUser;
//        self.sourceHashtag = @"";
//    }
//    return self;
//}

- (void)save {
    // Access token
    NSDictionary *dict = @{
        (id)kSecClass: (id)kSecClassInternetPassword,
        (id)kSecReturnAttributes: (id)kCFBooleanTrue,
        (id)kSecAttrServer: self.hostName,
        (id)kSecAttrAccount: self.accountId,
    };

    // Remove any old values from the keychain
    OSStatus err = SecItemDelete((__bridge CFDictionaryRef) dict);
    NSLog(@"Access token delete: %d", err);
    
    // Create dictionary of parameters to add
    dict = @{
        (id)kSecClass: (id)kSecClassInternetPassword,
        (id)kSecAttrType: [NSNumber numberWithUnsignedInt:'otok'],
        (id)kSecAttrServer: self.hostName,
        (id)kSecValueData: [self.accessToken dataUsingEncoding:NSUTF8StringEncoding],
        (id)kSecAttrAccount: self.accountId,
    };

    // Try to save to keychain
    err = SecItemAdd((__bridge CFDictionaryRef) dict, NULL);
    NSLog(@"Access token save: %d", err);
    
    // @{
    //   "hostname.com": @{
    //     @"user12345": @{
    //       @"accountId": @"user12345",
    //       @"url": @"https://.......",
    //       @"host": @"https://joinmastodon.org",
    //     }
    //   }
    // };
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *servers = [(NSDictionary*)[defaults objectForKey:@"BRMisskeyAccount"] mutableCopy] ?: [NSMutableDictionary dictionary];
    NSMutableDictionary *accounts = [(NSDictionary*)servers[self.hostName] mutableCopy] ?: [NSMutableDictionary dictionary];
    accounts[self.accountId] = [self dictionaryRepresentation];
    servers[self.hostName] = accounts;
    [defaults setObject:servers forKey:@"BRMisskeyAccount"];
    [defaults synchronize];
}

- (NSDictionary *)dictionaryRepresentation {
    return @{
        @"accountId": self.accountId,
        @"displayName": self.displayName,
        @"host": self.hostName,
//        @"expires": self.expires,
//        @"source": [[self class] stringRepresentationForStreamSource:self.source],
//        @"hashtag": self.sourceHashtag ?: @"",
//        @"listId": self.sourceListId ?: @"",
//        @"listName": self.sourceListName ?: @"",
    };
}

- (void)deleteAccount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *servers = [(NSDictionary*)[defaults objectForKey:@"BRMisskeyAccount"] mutableCopy] ?: [NSMutableDictionary dictionary];
    NSMutableDictionary *accounts = [(NSDictionary*)servers[self.hostName] mutableCopy] ?: [NSMutableDictionary dictionary];
    [accounts removeObjectForKey:self.accountId];
    servers[self.hostName] = accounts;
    [defaults setObject:servers forKey:@"BRMisskeyAccount"];
    [defaults synchronize];
    
    // Access token
    NSDictionary *dict = @{
        (id)kSecClass: (id)kSecClassInternetPassword,
        (id)kSecReturnAttributes: (id)kCFBooleanTrue,
        (id)kSecAttrServer: self.hostName,
        (id)kSecAttrAccount: self.accountId,
    };

    // Remove any old values from the keychain
    OSStatus err = SecItemDelete((__bridge CFDictionaryRef) dict);
    NSLog(@"Access token delete: %d", err);
}

- (NSString *)identifier {
    return [NSString stringWithFormat:@"%@:%@", self.hostName, self.accountId];
}

- (NSString *)shortDisplayName {
    return self.displayName;
}

//+ (NSString *)stringRepresentationForStreamSource:(BRMastodonStreamSource)source {
//    switch (source) {
//        case BRMastodonStreamSourceUser:
//            return @"user";
//        case BRMastodonStreamSourceUserNotification:
//            return @"user:notification";
//        case BRMastodonStreamSourceList:
//            return @"list";
//        case BRMastodonStreamSourceDirect:
//            return @"direct";
//        case BRMastodonStreamSourceHashtag:
//            return @"hashtag";
//        case BRMastodonStreamSourceHashtagLocal:
//            return @"hashtag:local";
//        case BRMastodonStreamSourcePublic:
//            return @"public";
//        case BRMastodonStreamSourcePublicLocal:
//            return @"public:local";
//        case BRMastodonStreamSourcePublicRemote:
//            return @"public:remote";
//    }
//    return nil;
//}

//+ (BRMastodonStreamSource)sourceWithStringRepresentation:(NSString *)string {
//    if ([string isEqualTo:@"user"]) {
//        return BRMastodonStreamSourceUser;
//    }
//    if ([string isEqualTo:@"user:notification"]) {
//        return BRMastodonStreamSourceUserNotification;
//    }
//    if ([string isEqualTo:@"list"]) {
//        return BRMastodonStreamSourceList;
//    }
//    if ([string isEqualTo:@"direct"]) {
//        return BRMastodonStreamSourceDirect;
//    }
//    if ([string isEqualTo:@"hashtag"]) {
//        return BRMastodonStreamSourceHashtag;
//    }
//    if ([string isEqualTo:@"hashtag:local"]) {
//        return BRMastodonStreamSourceHashtagLocal;
//    }
//    if ([string isEqualTo:@"public"]) {
//        return BRMastodonStreamSourcePublic;
//    }
//    if ([string isEqualTo:@"public:local"]) {
//        return BRMastodonStreamSourcePublicLocal;
//    }
//    if ([string isEqualTo:@"public:remote"]) {
//        return BRMastodonStreamSourcePublicRemote;
//    }
//    return BRMastodonStreamSourceUser;
//}

//- (NSString *)displayNameForStreamSource {
//    switch (self.source) {
//        case BRMastodonStreamSourceUser:
//            return NSLocalizedString(@"User", @"source name");
//        case BRMastodonStreamSourceUserNotification:
//            return NSLocalizedString(@"User Notification", @"source name");
//        case BRMastodonStreamSourceList:
//            return [NSString stringWithFormat:NSLocalizedString(@"List: %@", @"source name"), self.sourceListName];
//        case BRMastodonStreamSourceDirect:
//            return NSLocalizedString(@"Direct", @"source name");
//        case BRMastodonStreamSourceHashtag:
//            return [NSString stringWithFormat:NSLocalizedString(@"Hashtag: %@", @"source name"), self.sourceHashtag];
//        case BRMastodonStreamSourceHashtagLocal:
//            return [NSString stringWithFormat:NSLocalizedString(@"Hashtag Local: %@", @"source name"), self.sourceHashtag];
//        case BRMastodonStreamSourcePublic:
//            return NSLocalizedString(@"Public", @"source name");
//        case BRMastodonStreamSourcePublicLocal:
//            return NSLocalizedString(@"Public Local", @"source name");
//        case BRMastodonStreamSourcePublicRemote:
//            return NSLocalizedString(@"Public Remote", @"source name");
//    }
//    return nil;
//}

@end
