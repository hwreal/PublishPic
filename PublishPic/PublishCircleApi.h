//
//  PublishCircleApi.h
//  hwYTKDemo
//
//  Created by hwreal on 2021/10/8.
//

#import "YTKRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PublishCircleApi : YTKRequest
- (id)initWithImageUrls:(NSArray<NSString *> *)imageUrls text: (NSString *) text;

@end

NS_ASSUME_NONNULL_END
