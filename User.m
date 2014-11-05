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

- (id)initWithDictionary:(NSDictionary*)thisUserDict{
    self.userID=[NSString stringWithFormat:@"%@",[thisUserDict objectForKey:@"id_str"]];
    self.username=[thisUserDict objectForKey:@"screen_name"];
    self.screenName=[thisUserDict objectForKey:@"name"];
    self.profileImageURL=[NSURL URLWithString:[thisUserDict objectForKey:@"profile_image_url_https"]];
    self.description=[thisUserDict objectForKey:@"description"];
    
    NSArray *keys=[NSArray arrayWithObjects:@"created_at",@"follow_request_sent",@"followers_count",@"following",@"friends_count",@"geo_enabled",@"is_translator",@"lang",@"listed_count",
                   @"location",@"profile_background_color",@"profile_background_image_url_https",@"profile_link_color",@"profile_sidebar_border_color",@"profile_sidebar_fill_color",
                   @"profile_text_color",@"profile_use_background_image",@"protected",@"statuses_count",@"url",@"favourites_count",nil];
    for(__strong NSString *thisKey in keys){
        id object=[thisUserDict objectForKey:thisKey];
        if(object!=nil&&![object isKindOfClass:[NSNull class]]){
            if([thisKey isEqualToString:@"profile_background_image_url_https"]){
                thisKey=@"profile_background_image_url";
            }
            [self.otherInfos setObject:object forKey:thisKey];
        }
    }
    
    return self;
}

-(id)init{
	self= [super init];
	self.otherInfos=[NSMutableDictionary dictionary];
	return self;
}

-(BOOL)isEqual:(id)object{
	if(![object isKindOfClass:[self class]])return NO;
	User *thatAccount=(User*)object;
	if(thatAccount.type==self.type&&[thatAccount.userID isEqualToString:[self userID]])return YES;
	if(thatAccount.type==self.type&&[thatAccount.username isEqualToString:[self username]])return YES;
	return [super isEqual:object];
}

@end
