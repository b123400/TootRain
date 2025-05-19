//
//  StreamController.h
//  flood
//
//  Created by b123400 on 2/11/14.
//
//

#import <Foundation/Foundation.h>
#import "BRMastodonAccount.h"
#import "MastodonStatus.h"

@protocol StreamControllerDelegate <NSObject>

@optional
- (void)streamController:(id)controller didReceivedStatus:(Status *)status;

@end

@interface StreamController : NSObject

@property (nonatomic, weak) id<StreamControllerDelegate> delegate;

+ (instancetype)shared;

- (void)startStreamingWithAccount:(Account *)account;
- (void)disconnectStreamWithAccount:(Account *)account;
- (void)showStatus:(Status *)status;

@end
