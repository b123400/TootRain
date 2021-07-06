//
//  Status.m
//  Canvas
//
//  Created by b123400 Chan on 10/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "Status.h"

@implementation Status
@synthesize user,statusID,createdAt,text,favourited,reblogged,bookmarked,otherInfos,entities;

- (id)initWithMastodonStatus:(BRMastodonStatus *)status {
    if (self = [super init]) {
        self.user = [[User alloc] initWithMastodonUser:status.user];
        self.statusID = status.statusID;
        self.createdAt = status.createdAt;
        self.text = status.text;
        self.favourited = status.favourited;
        self.reblogged = status.reblogged;
        self.bookmarked = status.bookmarked;
    }
    return self;
}

@end
