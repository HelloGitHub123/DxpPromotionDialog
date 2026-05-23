#import <Foundation/Foundation.h>

@class DXPMktContactDto;

NS_ASSUME_NONNULL_BEGIN

@interface DXPQueryPromotionsResp : NSObject

@property (nonatomic, copy, nullable) NSString *resultCode;
@property (nonatomic, copy, nullable) NSString *resultMsg;
@property (nonatomic, copy, nullable) NSArray<DXPMktContactDto *> *data;

+ (instancetype)modelWithDictionary:(nullable NSDictionary *)dict;
+ (instancetype)modelWithJSONData:(nullable NSData *)data error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
