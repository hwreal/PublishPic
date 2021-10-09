//
//  PublishCircleApi.m
//  hwYTKDemo
//
//  Created by hwreal on 2021/10/8.
//

#import "PublishCircleApi.h"

@implementation PublishCircleApi{
    NSArray<NSString *> * _imageUrls;
    NSString * _text;
}

- (id)initWithImageUrls:(NSArray<NSString *> *)imageUrls text: (NSString *) text{
    self = [super init];
    if (self) {
        _imageUrls = imageUrls;
        _text = text;
    }
    return self;
}

- (NSString *)requestUrl{
    return @"/post?forWhat=publishCircle";
}

- (YTKRequestMethod)requestMethod{
    return YTKRequestMethodPOST;
}

- (id)requestArgument{
    return @{
        @"imageUrls": _imageUrls,
        @"text": _text
    };
}

- (YTKRequestSerializerType)requestSerializerType{
    return YTKRequestSerializerTypeJSON;
}

@end
