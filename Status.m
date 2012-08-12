//
//  Status.m
//  Canvas
//
//  Created by b123400 Chan on 10/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "Status.h"
#import "CJSONSerializer.h"
#import "NSString+UUID.h"

@implementation Status
@synthesize user,statusID,createdAt,text,liked,otherInfos;

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
-(NSString*)javascriptRepresentation{
	NSMutableDictionary *selfDict=[self dictionaryRepresentationToPlist:NO];
	NSMutableDictionary *randomStringDict=[NSMutableDictionary dictionary];
	NSArray *keys=[selfDict allKeys];
	for(NSString *key in keys){
		if([[selfDict objectForKey:key] isKindOfClass:[User class]]){
			User *thisUser=[selfDict objectForKey:key];
			NSString *randomString=[NSString stringWithNewUUID];
			[selfDict setObject:randomString forKey:key];
			[randomStringDict setObject:thisUser forKey:randomString];
		}
	}
	NSError *error=nil;
	NSData *jsonData=[[CJSONSerializer serializer] serializeDictionary:selfDict error:&error];
	NSString *jsonString=[[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]autorelease];
	
	for(NSString *key in randomStringDict){
		jsonString=[jsonString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\"%@\"",key] withString:[[randomStringDict objectForKey:key] javascriptRepresentation]];
	}
	return [NSString stringWithFormat:@"Status(%@)",jsonString];
}

-(BOOL)isEqual:(id)object{
	if(![object isKindOfClass:[self class]])return NO;
	Status *thatStatus=(Status*)object;
	if(thatStatus.user.type==user.type&&[thatStatus.statusID isEqualToString:statusID])return YES;
	return NO;
}

@end
