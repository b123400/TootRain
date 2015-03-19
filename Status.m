//
//  Status.m
//  Canvas
//
//  Created by b123400 Chan on 10/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "Status.h"

@implementation Status
@synthesize user,statusID,createdAt,text,liked,otherInfos,entities;

static NSDateFormatter *df=nil;

-(id)init{
	self=[super init];
	self.otherInfos=[NSMutableDictionary dictionary];
	return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary{
    self = [self init];
    
    self.statusID=[dictionary objectForKey:@"id_str"];
    if (!self.statusID) {
        return nil;
    }
    
    //parse user
    NSDictionary *userDict=[dictionary objectForKey:@"user"];
    User *thisUser=[[User alloc] initWithDictionary:userDict];
    self.user=thisUser;
    
    //Direct message
    NSDictionary *sender=[dictionary objectForKey:@"sender"];
    if(sender){
        self.user=[[User alloc] initWithDictionary:sender];
    }
    NSDictionary *recipient=[dictionary objectForKey:@"recipient"];
    if(recipient){
        [self.otherInfos setObject:[[User alloc] initWithDictionary:recipient] forKey:@"recipient"];
    }
    
    //parse date
    if(!df){
        df = [[NSDateFormatter alloc] init];
        [df setTimeStyle:NSDateFormatterFullStyle];
        [df setFormatterBehavior:NSDateFormatterBehavior10_4];
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [df setDateFormat:@"EEE LLL dd HH:mm:ss Z yyyy"];
    }
    self.createdAt=[df dateFromString:[dictionary objectForKey:@"created_at"]];
    
    if([dictionary objectForKey:@"retweeted_status"]){
        Status *retweetedStatus=[[Status alloc] initWithDictionary:[dictionary objectForKey:@"retweeted_status"]];
        [retweetedStatus.otherInfos setObject:self.createdAt forKey:@"retweetedAt"];
        [retweetedStatus.otherInfos setObject:self.user forKey:@"retweetedBy"];
        return retweetedStatus;
    }
    
    self.text=[dictionary objectForKey:@"text"];
    
    self.liked=[[dictionary objectForKey:@"favorited"] boolValue];
    
    if([dictionary objectForKey:@"entities"]){
        self.entities=[dictionary objectForKey:@"entities"];
    }
    
    NSArray *keys=[NSArray arrayWithObjects:@"coordinates",@"retweet_count",@"geo",@"retweeted",@"source",@"place",@"in_reply_to_screen_name",@"in_reply_to_status_id", nil];
    for(NSString *key in keys){
        if([dictionary objectForKey:key]&&[dictionary objectForKey:key]!=[NSNull null]){
            [self.otherInfos setObject:[dictionary objectForKey:key] forKey:key];
        }
    }
    
    return self;
}

-(BOOL)isEqual:(id)object{
	if(![object isKindOfClass:[self class]])return NO;
	Status *thatStatus=(Status*)object;
	if(thatStatus.user.type==user.type&&[thatStatus.statusID isEqualToString:statusID])return YES;
	return NO;
}

@end
