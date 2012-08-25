//
//  ComposeRequest.h
//  flood
//
//  Created by b123400 on 22/8/12.
//
//

#import "Request.h"
#import "Status.h"

@interface ComposeRequest : Request{
	NSString *text;
	Status *inReplyTo;
}
@property (strong,nonatomic) NSString *text;
@property (strong,nonatomic) Status *inReplyTo;

@end
