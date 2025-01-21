#import <Foundation/Foundation.h>

@interface IRCMessage : NSObject{
	
}
@property (strong, nonatomic) NSString *prefix;
@property (strong, nonatomic) NSString *command;
@property (strong, nonatomic) NSString *params;
@property (strong, nonatomic) NSString *trailing;
@property (strong, nonatomic) NSString *rawString;
@end
