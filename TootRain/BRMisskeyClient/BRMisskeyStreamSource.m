//
//  BRMisskeyStreamSource.m
//  TweetRain
//
//  Created by b123400 on 2022/12/26.
//

#import "BRMisskeyStreamSource.h"

@implementation BRMisskeyStreamSource

- (instancetype)initWithType:(BRMisskeyStreamSourceType)type {
    if (self = [super init]) {
        self.type = type;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        NSString *typeString = dict[@"type"];
        if ([typeString isEqualTo:@"global"]) {
            self.type = BRMisskeyStreamSourceTypeGlobal;
        } else if ([typeString isEqualTo:@"local"]) {
            self.type = BRMisskeyStreamSourceTypeLocal;
        } else if ([typeString isEqualTo:@"home"]) {
            self.type = BRMisskeyStreamSourceTypeHome;
        } else if ([typeString isEqualTo:@"hybrid"]) {
            self.type = BRMisskeyStreamSourceTypeHybrid;
        } else if ([typeString isEqualTo:@"main"]) {
            self.type = BRMisskeyStreamSourceTypeMain;
        } else if ([typeString isEqualTo:@"antenna"]) {
            self.type = BRMisskeyStreamSourceTypeAntenna;
            self.antennaId = dict[@"antennaId"];
            self.antennaName = dict[@"antennaName"];
        } else if ([typeString isEqualTo:@"userList"]) {
            self.type = BRMisskeyStreamSourceTypeUserList;
            self.userListId = dict[@"userListId"];
            self.userListName = dict[@"userListName"];
        } else if ([typeString isEqual:@"channel"]) {
            self.type = BRMisskeyStreamSourceTypeChannel;
            self.channelId = dict[@"channelId"];
            self.channelName = dict[@"channelName"];
        }
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    switch (self.type) {
        case BRMisskeyStreamSourceTypeGlobal:
            dict[@"type"] = @"global";
            break;
        case BRMisskeyStreamSourceTypeLocal:
            dict[@"type"] = @"local";
            break;
        case BRMisskeyStreamSourceTypeHome:
            dict[@"type"] = @"home";
            break;
        case BRMisskeyStreamSourceTypeHybrid:
            dict[@"type"] = @"hybrid";
            break;
        case BRMisskeyStreamSourceTypeMain:
            dict[@"type"] = @"main";
            break;
        case BRMisskeyStreamSourceTypeAntenna:
            dict[@"type"] = @"antenna";
            dict[@"antennaId"] = self.antennaId;
            dict[@"antennaName"] = self.antennaName;
            break;
        case BRMisskeyStreamSourceTypeUserList:
            dict[@"type"] = @"userList";
            dict[@"userListId"] = self.userListId;
            dict[@"userListName"] = self.userListName;
            break;
        case BRMisskeyStreamSourceTypeChannel:
            dict[@"type"] = @"channel";
            dict[@"channelId"] = self.channelId;
            dict[@"channelName"] = self.channelName;
    }
    return dict;
}

- (NSString *)displayName {
    switch (self.type) {
        case BRMisskeyStreamSourceTypeGlobal:
            return NSLocalizedString(@"Global Timeline", @"Misskey source type");
        case BRMisskeyStreamSourceTypeLocal:
            return NSLocalizedString(@"Local Timeline", @"Misskey source type");
        case BRMisskeyStreamSourceTypeHome:
            return NSLocalizedString(@"Home Timeline", @"Misskey source type");
        case BRMisskeyStreamSourceTypeHybrid:
            return NSLocalizedString(@"Hybrid Timeline", @"Misskey source type");
        case BRMisskeyStreamSourceTypeMain:
            return NSLocalizedString(@"Main (Reply and Renote)", @"Misskey source type");
        case BRMisskeyStreamSourceTypeAntenna:
            return [NSString stringWithFormat:NSLocalizedString(@"Antenna - %@", @"Misskey source type"), self.antennaName];
        case BRMisskeyStreamSourceTypeUserList:
            return [NSString stringWithFormat:NSLocalizedString(@"List - %@", @"Misskey source type"), self.userListName];
        case BRMisskeyStreamSourceTypeChannel:
            return [NSString stringWithFormat:NSLocalizedString(@"Channel - %@", @"Misskey source type"), self.channelName];
    }
}

- (NSString *)channelForAPI {
    switch (self.type) {
        case BRMisskeyStreamSourceTypeGlobal:
            return @"globalTimeline";
        case BRMisskeyStreamSourceTypeLocal:
            return @"localTimeline";
        case BRMisskeyStreamSourceTypeHome:
            return @"homeTimeline";
        case BRMisskeyStreamSourceTypeHybrid:
            return @"hybridTimeline";
        case BRMisskeyStreamSourceTypeMain:
            return @"main";
        case BRMisskeyStreamSourceTypeAntenna:
            return @"antenna";
        case BRMisskeyStreamSourceTypeUserList:
            return @"userList";
        case BRMisskeyStreamSourceTypeChannel:
            return @"channel";
    }
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[BRMisskeyStreamSource class]]) {
        BRMisskeyStreamSource *o = (BRMisskeyStreamSource*)object;
        return [[self dictionaryRepresentation] isEqual:[o dictionaryRepresentation]];
    }
    return NO;
}

- (NSUInteger)hash {
    return self.type ^ [self.antennaId hash] ^ [self.userListId hash] ^ [self.channelId hash];
}

+ (NSArray<BRMisskeyStreamSource*> *)defaultSources {
    return @[
        [[BRMisskeyStreamSource alloc] initWithType:BRMisskeyStreamSourceTypeHome],
        [[BRMisskeyStreamSource alloc] initWithType:BRMisskeyStreamSourceTypeMain],
        [[BRMisskeyStreamSource alloc] initWithType:BRMisskeyStreamSourceTypeLocal],
        [[BRMisskeyStreamSource alloc] initWithType:BRMisskeyStreamSourceTypeGlobal],
        [[BRMisskeyStreamSource alloc] initWithType:BRMisskeyStreamSourceTypeHybrid]
    ];
}

@end
