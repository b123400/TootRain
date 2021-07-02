//
//  MastodonApp.m
//  TweetRain
//
//  Created by b123400 on 2021/06/27.
//

#import "BRMastodonApp.h"
#import <Security/Security.h>

@implementation BRMastodonApp

- (instancetype)initWithHostName:(NSString *)hostName
                        clientId:(NSString *)clientId
                    clientSecret:(NSString *)clientSecret {
    if (self = [super init]) {
        self.hostName = hostName;
        self.clientId = clientId;
        self.clientSecret = clientSecret;
    }
    return self;
}

+ (instancetype)appWithHostname:(NSString *)hostName {
    // Create dictionary of search parameters
    NSDictionary *dict = @{
        (id)kSecClass: (id)kSecClassInternetPassword,
        (id)kSecAttrServer: hostName,
        (id)kSecReturnAttributes: (id)kCFBooleanTrue,
        (id)kSecAttrType: [NSNumber numberWithUnsignedInt:'oapp'],
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
    NSString *gotClientId = (NSString*) found[(id)kSecAttrAccount];
    NSString *gotClientSecret = [[NSString alloc] initWithData:found[(id)kSecValueData] encoding:NSUTF8StringEncoding];
    NSString *gotHostName = found[(id)kSecAttrServer];
    return [[BRMastodonApp alloc] initWithHostName:gotHostName
                                          clientId:gotClientId
                                      clientSecret:gotClientSecret];
}

- (void)save {
    NSDictionary *dict = @{
        (id)kSecClass: (id)kSecClassInternetPassword,
        (id)kSecAttrType: [NSNumber numberWithUnsignedInt:'oapp'],
        (id)kSecReturnAttributes: (id)kCFBooleanTrue,
        (id)kSecAttrServer: self.hostName,
    };

    // Remove any old values from the keychain
    OSStatus err = SecItemDelete((__bridge CFDictionaryRef) dict);
    NSLog(@"err1 %d", err);
    
    // Create dictionary of parameters to add
    dict = @{
        (id)kSecClass: (id)kSecClassInternetPassword,
        (id)kSecAttrType: [NSNumber numberWithUnsignedInt:'oapp'],
        (id)kSecAttrServer: self.hostName,
        (id)kSecValueData: [self.clientSecret dataUsingEncoding:NSUTF8StringEncoding],
        (id)kSecAttrAccount: self.clientId,
    };

    // Try to save to keychain
    err = SecItemAdd((__bridge CFDictionaryRef) dict, NULL);
    NSLog(@"err2 %d", err);
}

- (NSURL *)authorisationURL {
    NSURL *baseURL = [NSURL URLWithString:@"/oauth/authorize"
                            relativeToURL:[NSURL URLWithString:self.hostName]];
    NSURLComponents *components = [NSURLComponents componentsWithURL:baseURL resolvingAgainstBaseURL:YES];
    [components setQueryItems:@[
        [NSURLQueryItem queryItemWithName:@"response_type" value:@"code"],
        [NSURLQueryItem queryItemWithName:@"client_id" value:self.clientId],
        [NSURLQueryItem queryItemWithName:@"redirect_uri" value:OAUTH_REDIRECT_DEST],
        [NSURLQueryItem queryItemWithName:@"scope" value:@"read write"],
    ]];
    return [components URL];
}

@end
