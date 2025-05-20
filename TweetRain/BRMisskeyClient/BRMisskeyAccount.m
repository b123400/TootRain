//
//  BRMisskeyAccount.m
//  TweetRain
//
//  Created by b123400 on 2022/12/23.
//

#import "BRMisskeyAccount.h"
#import "BRMisskeyUser.h"

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
        self.displayName = dict[@"displayName"];
        
        if ([dict[@"streamSources"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *a = [NSMutableArray array];
            for (NSDictionary *sourceDict in dict[@"streamSources"]) {
                [a addObject:[[BRMisskeyStreamSource alloc] initWithDictionary:sourceDict]];
            }
            self.streamSources = a;
        } else {
            self.streamSources = @[];
        }
    }
    return self;
}

- (instancetype)initNewAccountWithHostName:(NSString *)hostName
                               accessToken:(NSString *)accessToken
                                 accountId:(NSString *)accountId
                                  username:(NSString *)username {
    if (self = [super init]) {
        self.hostName = hostName;
        self.accessToken = accessToken;
        self.accountId = accountId;
        self.displayName = [NSString stringWithFormat:@"@%@@%@", username, [[NSURL URLWithString:hostName] host]];
        BRMisskeyStreamSource *s = [[BRMisskeyStreamSource alloc] init];
        s.type = BRMisskeyStreamSourceTypeHome;
        self.streamSources = @[s];
    }
    return self;
}

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
        @"streamSources": [self.streamSources valueForKeyPath:@"dictionaryRepresentation"],
    };
}

- (NSImage *)serviceImage {
    return [NSImage imageNamed:@"Misskey"];
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

- (NSString *)displayNameForStreamSource {
    return [[self.streamSources valueForKeyPath:@"displayName"] componentsJoinedByString:@", "];
}

+ (NSMutableDictionary *)accountIdToEmojiDicts {
    static NSMutableDictionary<NSString *, NSDictionary<NSString *, BRMisskeyEmoji*>*> *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [NSMutableDictionary dictionary];
    });
    return dict;
}

- (void)setEmojiDict:(NSDictionary<NSString *, BRMisskeyEmoji *> *)dict {
    [[BRMisskeyAccount accountIdToEmojiDicts] setObject:dict forKey:self.accountId];
}

- (NSURL *)urlForEmoji:(NSString *)code host:(NSString * _Nullable)host {
    NSDictionary *emojiDict = [[BRMisskeyAccount accountIdToEmojiDicts] objectForKey:self.accountId];
    BRMisskeyEmoji *emoji = emojiDict[code];
    if (emoji.URL) {
        return emoji.URL;
    }
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:self.hostName];
    if (!host) {
        [urlComponents setPath:[NSString stringWithFormat:@"/emoji/%@.webp", code]];
    } else {
        [urlComponents setPath:[NSString stringWithFormat:@"/emoji/%@@%@.webp", code, host]];
    }
    return [urlComponents URL];
}

- (NSAttributedString *)attributedString:(NSString *)string
                                withHost:(NSString * _Nullable)host
                          emojisReplaced:(NSArray<BRMisskeyEmoji*>  * _Nullable)emojis
                                    {
    NSMutableString *text = [string mutableCopy];
    if (!emojis) {
        // Since misskey v13 the emojis field is gone from the response
        // Thank you @uakihir0 for this regex
        // https://github.com/uakihir0/SocialHub/commit/d6577a4fa535ba226fdf5e97bfbd1777d2048b17#diff-94352a4ed45b0f89971e682d1a08e80495c4dfa6685d5bde8b80dadf3f5a507bR867
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@":([a-zA-Z0-9_]+(@[a-zA-Z0-9-.]+)?):" options:0 error:nil];
        NSArray<NSTextCheckingResult*> *results = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        // Loop from back so replacing strings won't affect the range
        for (int i = results.count - 1; i >= 0; i--) {
            NSTextCheckingResult *r = results[i];
            NSRange range = [r rangeAtIndex:0];
            NSString *emojiToken = [[text substringWithRange:range] stringByReplacingOccurrencesOfString:@":" withString:@""]; // e.g. ":hello:" "hello@example.com"
            NSURL *emojiURL = [self urlForEmoji:emojiToken host:host];
            [text replaceCharactersInRange:range withString:[NSString stringWithFormat:@"<img src=\"%@\">", emojiURL.absoluteString]];
        }
    } else {
        for (BRMisskeyEmoji *emoji in emojis) {
            [text replaceOccurrencesOfString:[NSString stringWithFormat:@":%@:", emoji.name]
                                  withString:[NSString stringWithFormat:@"<img src=\"%@\">", emoji.URL.absoluteString]
                                     options:NSCaseInsensitiveSearch
                                       range:NSMakeRange(0, text.length)];
        }
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
