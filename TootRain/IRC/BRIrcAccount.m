//
//  BRIrcAccount.m
//  TweetRain
//
//  Created by b123400 on 2025/01/20.
//

#import "BRIrcAccount.h"

@implementation BRIrcAccount

+ (NSArray<BRIrcAccount*> *)allAccounts {
    NSMutableArray *result = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *dicts = (NSArray*)[defaults objectForKey:@"BRIrcAccount"];
    if (!dicts) {
        return result;
    }
    for (NSDictionary *dict in dicts) {
        BRIrcAccount *account = [BRIrcAccount accountWithDict:dict];
        if (account) {
            [result addObject:account];
        }
    }
    return result;
}

+ (BRIrcAccount *)accountWithDict:(NSDictionary *)accountDict {
    BRIrcAccount *acc = [[BRIrcAccount alloc] init];
    acc.uuid = accountDict[@"uuid"];
    acc.host = accountDict[@"host"];
    acc.port = [accountDict[@"port"] integerValue];
    acc.nick = accountDict[@"nick"];
    acc.tls = [accountDict[@"tls"] boolValue];
    acc.channels = accountDict[@"channels"];
    
    // Save Pass in keychain
    NSDictionary *dict = @{
        (id)kSecClass: (id)kSecClassInternetPassword,
        (id)kSecAttrServer: [NSString stringWithFormat:@"%@:%ld", acc.host, acc.port],
        (id)kSecReturnAttributes: (id)kCFBooleanTrue,
        (id)kSecAttrType: [NSNumber numberWithUnsignedInt:'pass'],
        (id)kSecAttrAccount: acc.nick,
        (id)kSecReturnData: (id)kCFBooleanTrue
    };

    // Look up server in the keychain
    NSDictionary *found = nil;
    CFDictionaryRef foundCF;
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef) dict, (CFTypeRef*)&foundCF);

    // Check if found
    found = (__bridge NSDictionary*)(foundCF);
    if (!found) {
        acc.pass = nil;
    } else {
        // Found
        NSString *pass = [[NSString alloc] initWithData:found[(id)kSecValueData] encoding:NSUTF8StringEncoding];
        acc.pass = pass;
    }
    
    return acc;
}

- (void)save {
    NSDictionary *dict = @{
        (id)kSecClass: (id)kSecClassInternetPassword,
        (id)kSecReturnAttributes: (id)kCFBooleanTrue,
        (id)kSecAttrServer: [NSString stringWithFormat:@"%@:%ld", self.host, self.port],
        (id)kSecAttrAccount: self.nick,
    };
    
    // Remove any old values from the keychain
    OSStatus err = SecItemDelete((__bridge CFDictionaryRef) dict);

    if (self.pass.length) {
        
        // Create dictionary of parameters to add
        dict = @{
            (id)kSecClass: (id)kSecClassInternetPassword,
            (id)kSecAttrType: [NSNumber numberWithUnsignedInt:'pass'],
            (id)kSecAttrServer: [NSString stringWithFormat:@"%@:%ld", self.host, self.port],
            (id)kSecValueData: [self.pass dataUsingEncoding:NSUTF8StringEncoding],
            (id)kSecAttrAccount: self.nick,
        };
        
        // Try to save to keychain
        err = SecItemAdd((__bridge CFDictionaryRef) dict, NULL);
        NSLog(@"Pass saved: %d", err);
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *accounts = [(NSArray*)[defaults objectForKey:@"BRIrcAccount"] mutableCopy] ?: [NSMutableArray array];
    BOOL found = NO;
    NSUInteger i = 0;
    for (NSDictionary *dict in accounts) {
        if ([dict[@"uuid"] isEqual:self.uuid]) {
            found = YES;
            break;
        }
        i++;
    }
    if (!found) {
        [accounts addObject:[self dictionaryRepresentation]];
    } else {
        accounts[i] = [self dictionaryRepresentation];
    }
    
    [defaults setObject:accounts forKey:@"BRIrcAccount"];
    [defaults synchronize];
}

- (NSDictionary *)dictionaryRepresentation {
    return @{
        @"uuid": self.uuid ?: [NSUUID UUID].UUIDString,
        @"host": self.host ?: @"",
        @"port": @(self.port),
        @"nick": self.nick ?: @"",
        @"tls": @(self.tls),
        @"channels": self.channels ?: @[],
    };
}

- (NSString *)identifier {
    return self.uuid;
}
- (NSString *)displayName {
    return [NSString stringWithFormat:@"%@@%@", self.nick, self.host];
}
- (NSString *)shortDisplayName {
    return self.displayName;
}

- (NSImage *)serviceImage {
    return [NSImage imageNamed:@"IRC"];
}

- (void)deleteAccount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *accounts = [(NSArray*)[defaults objectForKey:@"BRIrcAccount"] mutableCopy] ?: [NSMutableArray array];
    BOOL found = NO;
    NSUInteger i = 0;
    for (NSDictionary *dict in accounts) {
        if ([dict[@"uuid"] isEqual:self.uuid]) {
            found = YES;
            break;
        }
        i++;
    }
    
    if (found) {
        [accounts removeObjectAtIndex:i];
    }
    [defaults setObject:accounts forKey:@"BRIrcAccount"];
    [defaults synchronize];
}

@end
