//
//  StreamController.h
//  flood
//
//  Created by b123400 on 2/11/14.
//
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

@protocol StreamControllerDelegate <NSObject>

@optional
- (void)streamController:(id)controller didReceivedTweet:(id)tweet;

@end

@interface StreamController : NSObject

@property (nonatomic, weak) id<StreamControllerDelegate> delegate;
@property (nonatomic, strong) NSString *searchTerm;

+ (instancetype)shared;

- (id)initWithAccount:(ACAccount*)account;
- (void)startStreaming;

@end
