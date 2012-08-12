//
//  SSToken.m
//  OAuthery
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SSToken.h"


@implementation SSToken

@synthesize tokenBody, pin, screenName, userID;

-(id)initWithHTTPResponseBody:(NSString *)body{
	self = [super initWithHTTPResponseBody:body];
	if(self){
		tokenBody = [body copy];
		
		NSArray *pairs = [body componentsSeparatedByString:@"&"];
		for (NSString *pair in pairs) {
			NSArray *elements = [pair componentsSeparatedByString:@"="];
			[self parseHTTPKey:[elements objectAtIndex:0] value:[elements objectAtIndex:1]];
		}
	}
	return self;
}

-(void)parseHTTPKey:(NSString *)paramKey value:(id)body{
	if ([paramKey isEqualToString:@"screen_name"]) {
		screenName = [body copy];
	}else if([paramKey isEqualToString:@"user_id"]){
		userID = ((unsigned long long)[body longLongValue]);
	}
}

-(NSString *)verifier{
	return self.pin;
}

-(NSDictionary *)parameters{
	NSMutableDictionary *params = [[[super parameters] mutableCopy] autorelease];
	if([self verifier]){
		[params setObject:[self verifier] forKey:@"oauth_verifier"];
	}
	return params;
}

-(void)dealloc{
	[tokenBody release];
	tokenBody = nil;
	
	[pin release];
	pin = nil;
	
	[screenName release];
	screenName = nil;
	
	[super dealloc];
}

@end
