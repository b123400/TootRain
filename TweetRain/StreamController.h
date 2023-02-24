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

- (void)startStreaming;
- (void)showStatus:(Status *)status;

@end
