#import "DXPPromotionAPIClient.h"
#import "DXPQueryPromotionsResp.h"
#import "DXPQueryAllChannelsResp.h"
#import "DXPChannelReq.h"
#import "DXPGlobalStorage.h"
#import "DXPPromoUserData.h"
#import "DXPJSONHelper.h"
#import "DXPPromotionTags.h"
#import <DXPNetWorkingManagerLib/DCNetAPIClient.h>

#if __has_include(<DXPNetWorkingManagerLib/DXPNetWorkingManager.h>)
#import <DXPNetWorkingManagerLib/DXPNetWorkingManager.h>
#define DXP_HAS_NETWORK_LIB 1
#endif

@implementation DXPPromotionAPIClient

#pragma mark - Response logging

- (void)logResponseWithMethod:(NSString *)method
                          url:(NSString *)url
               responseObject:(nullable id)responseObject {
    NSString *body = nil;
    if ([responseObject isKindOfClass:[NSDictionary class]] || [responseObject isKindOfClass:[NSArray class]]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:responseObject
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
        if (data) {
            body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    if (!body.length) {
        body = responseObject ? [responseObject description] : @"(null)";
    }
    NSLog(@"[%@] %@ %@\n返回报文:\n%@", DXPPromotionTagAPI, method, url, body);
}

- (void)logFailureWithMethod:(NSString *)method
                         url:(NSString *)url
                       error:(nullable NSString *)errorMessage {
    NSLog(@"[%@] %@ %@ 请求失败: %@", DXPPromotionTagAPI, method, url, errorMessage ?: @"unknown");
}

+ (instancetype)sharedClient {
    static DXPPromotionAPIClient *client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[DXPPromotionAPIClient alloc] init];
    });
    return client;
}

- (NSString *)dxpUrl {
	return [DCNetAPIClient sharedClient].baseUrl;;
}

#pragma mark - DXPNetWorkingManagerLib bridge

- (void)GET:(NSString *)url
 parameters:(nullable NSDictionary *)parameters
    success:(void(^)(NSDictionary *json))success
    failure:(DXPPromotionAPIFailureBlock)failure {
#ifdef DXP_HAS_NETWORK_LIB
    DXPNetWorkingManager *manager = [DXPNetWorkingManager sharedManager];
    if ([manager respondsToSelector:@selector(GET:parameters:success:failure:)]) {
        [manager GET:url parameters:parameters success:^(id responseObject) {
            [self logResponseWithMethod:@"GET" url:url responseObject:responseObject];
            NSDictionary *dict = [responseObject isKindOfClass:[NSDictionary class]] ? responseObject : nil;
            if (success) success(dict);
        } failure:^(NSError *error) {
            [self logFailureWithMethod:@"GET" url:url error:error.localizedDescription];
            if (failure) failure(nil, error.localizedDescription);
        }];
        return;
    }
    if ([manager respondsToSelector:@selector(requestWithURL:method:parameters:success:failure:)]) {
        [manager requestWithURL:url method:@"GET" parameters:parameters success:^(id responseObject) {
            [self logResponseWithMethod:@"GET" url:url responseObject:responseObject];
            NSDictionary *dict = [responseObject isKindOfClass:[NSDictionary class]] ? responseObject : nil;
            if (success) success(dict);
        } failure:^(NSError *error) {
            [self logFailureWithMethod:@"GET" url:url error:error.localizedDescription];
            if (failure) failure(nil, error.localizedDescription);
        }];
        return;
    }
#endif
    [self fallbackGET:url parameters:parameters success:success failure:failure];
}

- (void)POST:(NSString *)url
    body:(NSDictionary *)body
   success:(void(^)(NSDictionary *json))success
   failure:(DXPPromotionAPIFailureBlock)failure {
#ifdef DXP_HAS_NETWORK_LIB
    DXPNetWorkingManager *manager = [DXPNetWorkingManager sharedManager];
    if ([manager respondsToSelector:@selector(POST:parameters:success:failure:)]) {
        [manager POST:url parameters:body success:^(id responseObject) {
            [self logResponseWithMethod:@"POST" url:url responseObject:responseObject];
            NSDictionary *dict = [responseObject isKindOfClass:[NSDictionary class]] ? responseObject : nil;
            if (success) success(dict);
        } failure:^(NSError *error) {
            [self logFailureWithMethod:@"POST" url:url error:error.localizedDescription];
            if (failure) failure(nil, error.localizedDescription);
        }];
        return;
    }
    if ([manager respondsToSelector:@selector(requestWithURL:method:parameters:success:failure:)]) {
        [manager requestWithURL:url method:@"POST" parameters:body success:^(id responseObject) {
            [self logResponseWithMethod:@"POST" url:url responseObject:responseObject];
            NSDictionary *dict = [responseObject isKindOfClass:[NSDictionary class]] ? responseObject : nil;
            if (success) success(dict);
        } failure:^(NSError *error) {
            [self logFailureWithMethod:@"POST" url:url error:error.localizedDescription];
            if (failure) failure(nil, error.localizedDescription);
        }];
        return;
    }
#endif
    [self fallbackPOST:url body:body success:success failure:failure];
}

#pragma mark - NSURLSession fallback (Demo / 无 Pod 时)

- (void)fallbackGET:(NSString *)urlString
         parameters:(NSDictionary *)parameters
            success:(void(^)(NSDictionary *json))success
            failure:(DXPPromotionAPIFailureBlock)failure {
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
    NSMutableArray *items = [NSMutableArray array];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj) {
            [items addObject:[NSURLQueryItem queryItemWithName:[key description] value:[DXPJSONHelper stringFromObject:obj]]];
        }
    }];
    components.queryItems = items;
    NSURLRequest *request = [NSURLRequest requestWithURL:components.URL];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self logFailureWithMethod:@"GET" url:urlString error:error.localizedDescription];
                if (failure) failure(nil, error.localizedDescription);
                return;
            }
            NSError *jsonError = nil;
            id json = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError] : nil;
            if (![json isKindOfClass:[NSDictionary class]]) {
                NSString *raw = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
                [self logResponseWithMethod:@"GET" url:urlString responseObject:raw ?: json];
                if (failure) failure(nil, jsonError.localizedDescription ?: @"Invalid JSON");
                return;
            }
            [self logResponseWithMethod:@"GET" url:urlString responseObject:json];
            if (success) success(json);
        });
    }] resume];
}

- (void)fallbackPOST:(NSString *)urlString
                body:(NSDictionary *)body
             success:(void(^)(NSDictionary *json))success
             failure:(DXPPromotionAPIFailureBlock)failure {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *token = [DXPPromoUserData sharedInstance].token;
    if (![DXPJSONHelper isEmptyString:token]) {
        [request setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
    }
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self logFailureWithMethod:@"POST" url:urlString error:error.localizedDescription];
                if (failure) failure(nil, error.localizedDescription);
                return;
            }
            id json = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
            if (![json isKindOfClass:[NSDictionary class]]) {
                NSString *raw = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
                [self logResponseWithMethod:@"POST" url:urlString responseObject:raw ?: json];
                if (failure) failure(nil, @"Invalid JSON");
                return;
            }
            [self logResponseWithMethod:@"POST" url:urlString responseObject:json];
            if (success) success(json);
        });
    }] resume];
}

#pragma mark - Public API

- (void)fetchPromotionsWithSubsId:(NSNumber *)subsId
                          channel:(NSString *)channel
                           adSlot:(NSString *)adSlot
                    serviceNumber:(NSString *)serviceNumber
                          success:(void (^)(DXPQueryPromotionsResp *))success
                          failure:(DXPPromotionAPIFailureBlock)failure {
    NSString *base = [DCNetAPIClient sharedClient].baseUrl;
    if ([DXPJSONHelper isEmptyString:base]) {
        if (failure) failure(nil, @"DXP URL is null");
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@/dxp/promotion-management/v1/promotions", base];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (subsId) params[@"subsId"] = subsId;
    if (channel) params[@"channel"] = channel;
    if (adSlot) params[@"adSlot"] = adSlot;
    if (serviceNumber) params[@"serviceNumber"] = serviceNumber;

//    [self GET:url parameters:params success:^(NSDictionary *json) {
//        DXPQueryPromotionsResp *resp = [DXPQueryPromotionsResp modelWithDictionary:json];
//        if (success) success(resp);
//    } failure:failure];
	
	[[DCNetAPIClient sharedClient] GET:url paramaters:params CompleteBlock:^(id json, NSError *error) {
		if (!error) {
			DXPQueryPromotionsResp *resp = [DXPQueryPromotionsResp modelWithDictionary:json];
			if (success) success(resp);
		} else {
			if (failure) failure(nil, @"DXP request fail");
		}
	}];
}

- (void)reportStatusWithTransactionSn:(NSString *)transactionSn
                               status:(NSString *)status
                              success:(void (^)(DXPQueryAllChannelsResp *))success
                              failure:(DXPPromotionAPIFailureBlock)failure {
	NSString *base = [DCNetAPIClient sharedClient].baseUrl;
    if ([DXPJSONHelper isEmptyString:base]) {
        if (failure) failure(nil, @"DXP URL is null");
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@/dxp/common-management/v1/channels/inapp/webhook/status", base];
    DXPChannelReq *req = [[DXPChannelReq alloc] init];
    req.transactionSn = transactionSn;
    req.status = status;
    [self POST:url body:[req toDictionary] success:^(NSDictionary *json) {
        DXPQueryAllChannelsResp *resp = [DXPQueryAllChannelsResp modelWithDictionary:json];
        if (success) success(resp);
    } failure:failure];
}

@end
