//
//  MastodonStatus.m
//  TweetRain
//
//  Created by b123400 on 2021/07/07.
//

#import "MastodonStatus.h"
#import "MastodonUser.h"

@implementation MastodonStatus

- (id)initWithMastodonStatus:(BRMastodonStatus *)status {
    if (self = [super init]) {
        self.user = [[MastodonUser alloc] initWithMastodonUser:status.user];
        self.statusID = status.statusID;
        self.createdAt = status.createdAt;
        self.text = status.text;
        self.favourited = status.favourited;
        self.reblogged = status.reblogged;
        self.bookmarked = status.bookmarked;
        
        self.mastodonStatus = status;
    }
    return self;
}

@end
