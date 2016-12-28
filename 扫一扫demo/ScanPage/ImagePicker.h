//
//  ImagePicker.h
//  ykbme_ios
//
//  Created by Alion on 16/12/21.
//  Copyright © 2016年 Chengdu Sanfast Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ImagePickerCompletionHandler)(NSData *data, UIImage *image);

typedef NS_ENUM(NSUInteger, SourceType) {
    SourceTypeAll,
    SourceTypePhotoLibrary,
    SourceTypeCamera
};

@interface ImagePicker : NSObject

+ (ImagePicker *)sharedInstance;

- (void)pickImageIn:(__kindof UIViewController *)viewController
       bySourceType:(SourceType)sourceType
      allowsEditing:(BOOL)allowsEditing
withCompletionHandler:(ImagePickerCompletionHandler)completionHandler;

@end
