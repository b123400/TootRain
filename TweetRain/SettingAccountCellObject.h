//
//  SettingAccountCellObject.h
//  TweetRain
//
//  Created by b123400 on 2022/11/29.
//

#import <Foundation/Foundation.h>
#import "SettingManager.h"
#import "BRMastodonClient/BRMastodonAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface SettingAccountCellObject : NSObject

@property (strong, nonatomic) NSImage *serviceImage;
@property (strong, nonatomic) NSString *accountName;
@property (assign) BOOL isConnected;

@end

NS_ASSUME_NONNULL_END
