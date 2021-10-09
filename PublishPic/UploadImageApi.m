//
//  UploadImageApi.m
//  hwYTKDemo
//
//  Created by hwreal on 2021/10/8.
//

#import "UploadImageApi.h"

@implementation UploadImageApi{
    UIImage *_image;
    NSUInteger _index;
}

- (id)initWithImage:(UIImage *)image index: (NSUInteger) index{
    self = [super init];
    if (self) {
        _image = image;
        _index = index;
    }
    return self;
}

- (NSString *)requestUrl{
    return @"/post?forWhat=uploadImage";
}

- (YTKRequestMethod)requestMethod{
    return YTKRequestMethodPOST;
}

- (id)requestArgument{
    return @{
        @"image": [NSString stringWithFormat:@"img_%d",_index],
        @"index": [NSNumber numberWithUnsignedInt:_index]
    };
}

- (YTKRequestSerializerType)requestSerializerType{
    return YTKRequestSerializerTypeJSON;
}

- (NSString *)imageUrl{
    return  [NSString stringWithFormat:@"https://xxx.com/%@.jpg",[[self.responseJSONObject objectForKey:@"json"] objectForKey:@"image"]] ;
}


@end
