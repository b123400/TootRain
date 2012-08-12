//
//  SSToken.h
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

#import <Foundation/Foundation.h>
#import "OAToken.h"

typedef unsigned long long SSTwitterID;

@interface SSToken : OAToken {
	NSString *tokenBody;
	NSString *pin;
	
	NSString *screenName;
	SSTwitterID userID;
}

@property (copy) NSString *pin;
@property (nonatomic, readonly) NSString *tokenBody;

@property (nonatomic, readonly) NSString *screenName;
@property (nonatomic, readonly) SSTwitterID userID;

// the Twitter OAuth implementation sets the oauth_verifier to the PIN
-(NSString *)verifier;

-(void)parseHTTPKey:(NSString *)paramKey value:(id)body;

@end
