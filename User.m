//
//  Account.m
//  Smarkin
//
//  Created by b123400 on 07/05/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "User.h"
#import "CJSONSerializer.h"

@implementation User
@synthesize type,username,userID,screenName,otherInfos,profileImageURL,description;

+(NSString*)networkNameOfType:(BRUserType)type{
	switch (type) {
		case BRUserTypeTwitter:
			return @"twitter";
			break;
		case BRUserTypeFacebook:
			return @"facebook";
			break;
		default:
			break;
	}
	return nil;
}
+(BRUserType)typeOfNetworkName:(NSString*)networkName{
	networkName=[networkName lowercaseString];
	if([networkName isEqualToString:@"twitter"]){
		return BRUserTypeTwitter;
	}else if([networkName isEqualToString:@"facebook"]){
		return BRUserTypeFacebook;
	}
	return BRUserTypeUnknown;
}

+(User*)userWithDictionary:(NSDictionary*)dict{
	User *thisUser=[[User alloc] init];
	thisUser=[thisUser insertDataIntoUser:thisUser WithDictionary:dict];
	
	return thisUser;
}
-(User*)insertDataIntoUser:(User*)thisUser WithDictionary:(NSDictionary*)dict{
	thisUser.type=[[dict objectForKey:@"type"] intValue];
	thisUser.username=[dict objectForKey:@"username"];
	thisUser.userID=[dict objectForKey:@"userID"];
	thisUser.screenName=[dict objectForKey:@"screenName"];
	thisUser.otherInfos=[dict objectForKey:@"otherInfos"];
	thisUser.profileImageURL=[NSURL URLWithString:[dict objectForKey:@"profileImageURL"]];
	thisUser.description=[dict objectForKey:@"description"];
	return thisUser;
}
-(id)init{
	self= [super init];
	self.otherInfos=[NSMutableDictionary dictionary];
	return self;
}

-(NSDictionary*)dictionaryRepresentation{	
	NSMutableDictionary *resultDict=[NSMutableDictionary dictionary];
	if(username)[resultDict setObject:username forKey:@"username"];
	if(userID)[resultDict setObject:userID forKey:@"userID"];
	[resultDict setObject:[NSNumber numberWithInt:type] forKey:@"type"];
	if(screenName)[resultDict setObject:screenName forKey:@"screenName"];
	if(profileImageURL)[resultDict setObject:[profileImageURL absoluteString] forKey:@"profileImageURL"];
	if(description)[resultDict setObject:description forKey:@"description"];
	
	for(NSString *key in otherInfos){
		[resultDict setObject:[otherInfos objectForKey:key] forKey:key];
	}
	return resultDict;
}
-(NSString*)javascriptRepresentation{
	NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:[self dictionaryRepresentation]];
	[dict setObject:[User networkNameOfType:self.type] forKey:@"type"];
	[dict setObject:[NSString stringWithFormat:@"%@@%@",[dict objectForKey:@"userID"],[dict objectForKey:@"type"]] forKey:@"userID"];
	
	NSError *error=nil;
	NSData *jsonData=[[CJSONSerializer serializer] serializeDictionary:dict error:&error];
	NSString *jsonString=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
	
	return [NSString stringWithFormat:@"User(%@)",jsonString];
}

-(BOOL)isEqual:(id)object{
	if(![object isKindOfClass:[self class]])return NO;
	User *thatAccount=(User*)object;
	if(thatAccount.type==self.type&&[thatAccount.userID isEqualToString:[self userID]])return YES;
	if(thatAccount.type==self.type&&[thatAccount.username isEqualToString:[self username]])return YES;
	return [super isEqual:object];
}

@end
