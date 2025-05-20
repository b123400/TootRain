//
//  BRMastodonInstanceInfo.m
//  TweetRain
//
//  Created by b123400 on 2025/04/01.
//

#import "BRMastodonInstanceInfo.h"

@implementation BRMastodonInstanceInfo

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        NSString *versionString = dictionary[@"version"];
        if ([versionString containsString:@"Pleroma"]) {
            self.software = BRMastodonInstanceSoftwarePleroma;
        } else if ([versionString containsString:@"Akkoma"]) {
            self.software = BRMastodonInstanceSoftwareAkkoma;
        } else if ([versionString containsString:@"hometown"]) {
            self.software = BRMastodonInstanceSoftwareHometown;
        }
    }
    return self;
}

@end
