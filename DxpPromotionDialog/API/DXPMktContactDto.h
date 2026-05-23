#import <Foundation/Foundation.h>

@class DXPMktCreativeInfo;

NS_ASSUME_NONNULL_BEGIN

@interface DXPMktContactDto : NSObject

@property (nonatomic, strong, nullable) NSNumber *subsId;
@property (nonatomic, copy, nullable) NSString *serviceNumber;
@property (nonatomic, copy, nullable) NSString *channel;
@property (nonatomic, copy, nullable) NSString *adSlot;
@property (nonatomic, strong, nullable) NSNumber *contactId;
@property (nonatomic, strong, nullable) NSNumber *batchId;
@property (nonatomic, copy, nullable) NSString *batchCode;
@property (nonatomic, copy, nullable) NSString *campaignCode;
@property (nonatomic, copy, nullable) NSString *campaignName;
@property (nonatomic, copy, nullable) NSArray<DXPMktCreativeInfo *> *recommendedWordsList;

+ (instancetype)modelWithDictionary:(nullable NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
