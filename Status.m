//
//  Status.m
//  Canvas
//
//  Created by b123400 Chan on 10/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "Status.h"
#import "CJSONSerializer.h"

@implementation Status
@synthesize user,statusID,createdAt,text,liked,otherInfos,entities;

-(id)init{
	self=[super init];
	self.otherInfos=[NSMutableDictionary dictionary];
	return self;
}
-(NSMutableDictionary*)dictionaryRepresentationToPlist:(BOOL)toPlist{
	NSMutableDictionary *dict=[NSMutableDictionary dictionary];
	if(toPlist){
		[dict setObject:[user dictionaryRepresentation] forKey:@"user"];
	}else{
		[dict setObject:user forKey:@"user"];
	}
	[dict setObject:statusID forKey:@"statusID"];
	[dict setObject:[NSNumber numberWithDouble:[createdAt timeIntervalSince1970]*1000.0f] forKey:@"createdAt"];
	[dict setObject:text forKey:@"text"];
	[dict setObject:[NSNumber numberWithBool:liked] forKey:@"liked"];
	for(NSString *key in otherInfos){
		if([key isEqualToString:@"retweetedAt"]){
			[dict setObject:[NSNumber numberWithDouble:[[otherInfos objectForKey:@"retweetedAt"] timeIntervalSince1970]*1000.0f] forKey:@"retweetedAt"];
		}else{
			[dict setObject:[otherInfos objectForKey:key] forKey:key];
		}
	}
	return dict;
}
-(NSMutableDictionary*)dictionaryRepresentation{
	return [self dictionaryRepresentationToPlist:YES];
}

-(BOOL)isEqual:(id)object{
	if(![object isKindOfClass:[self class]])return NO;
	Status *thatStatus=(Status*)object;
	if(thatStatus.user.type==user.type&&[thatStatus.statusID isEqualToString:statusID])return YES;
	return NO;
}

@end
