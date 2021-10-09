//
//  UploadImageApi.h
//  hwYTKDemo
//
//  Created by hwreal on 2021/10/8.
//

#import "YTKRequest.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UploadImageApi : YTKRequest

- (id)initWithImage:(UIImage *)image index: (NSUInteger) index;

- (NSString *)imageUrl;
@end

NS_ASSUME_NONNULL_END
