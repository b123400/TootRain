//
//  MisskeyUser.h
//  TweetRain
//
//  Created by b123400 on 2022/12/24.
//

#import "User.h"
#import "BRMisskeyUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface MisskeyUser : User

@property (nonatomic, strong) BRMisskeyUser* misskeyUser;
@property (nonatomic, strong) NSAttributedString *attributedScreenName;

- (instancetype)initWithMisskeyUser:(BRMisskeyUser *)user;

@end

NS_ASSUME_NONNULL_END
