//
//  BRMisskeyStreamSource.h
//  TweetRain
//
//  Created by b123400 on 2022/12/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    BRMisskeyStreamSourceTypeGlobal,
    BRMisskeyStreamSourceTypeLocal,
    BRMisskeyStreamSourceTypeHome,
    BRMisskeyStreamSourceTypeHybrid,
    BRMisskeyStreamSourceTypeMain,
    BRMisskeyStreamSourceTypeAntenna,
    BRMisskeyStreamSourceTypeUserList,
} BRMisskeyStreamSourceType;

@interface BRMisskeyStreamSource : NSObject

@property (nonatomic, assign) BRMisskeyStreamSourceType type;

@property (nonatomic, strong) NSString *antennaId;
@property (nonatomic, strong) NSString *antennaName;
@property (nonatomic, strong) NSString *userListId;
@property (nonatomic, strong) NSString *userListName;

+ (NSArray<BRMisskeyStreamSource*> *)defaultSources;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;
- (NSString *)displayName;

@end

NS_ASSUME_NONNULL_END
