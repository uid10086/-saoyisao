//
//  ImagePicker.h
//  ykbme_ios
//
//  Created by Alion on 16/12/21.
//  Copyright © 2016年 Chengdu Sanfast Technology Co., Ltd. All rights reserved.
//

#import "ImagePicker.h"

@interface ImagePicker () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) __kindof UIViewController *viewController;
@property (nonatomic, assign) SourceType sourceType;
@property (nonatomic, assign) BOOL allowsEditing;

@property (nonatomic, retain) UIActionSheet *actionSheet;
@property (nonatomic, retain) UIImagePickerController *imagePicker;
@property (nonatomic, copy) ImagePickerCompletionHandler completionHandler;

@end

@implementation ImagePicker

+ (ImagePicker *)sharedInstance
{
    static ImagePicker *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ImagePicker alloc] init];
    });
    return sharedInstance;
}

- (void)pickImageIn:(__kindof UIViewController *)viewController
       bySourceType:(SourceType)sourceType
      allowsEditing:(BOOL)allowsEditing
withCompletionHandler:(ImagePickerCompletionHandler)completionHandler
{
    self.viewController = viewController;
    self.sourceType = sourceType;
    self.allowsEditing = allowsEditing;
    self.completionHandler = completionHandler;
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
    switch (self.sourceType) {
        case SourceTypeAll:
        {
            [self.actionSheet addButtonWithTitle:@"拍照"];
            [self.actionSheet addButtonWithTitle:@"从相册选择"];
        }
            break;
        case SourceTypePhotoLibrary:
        {
            [self.actionSheet addButtonWithTitle:@"从相册选择"];
        }
            break;
        case SourceTypeCamera:
        {
            [self.actionSheet addButtonWithTitle:@"拍照"];
        }
            break;
            
        default:
            break;
    }
    [self.actionSheet showInView:self.viewController.view];
}

#pragma mark - delegates
#pragma mark <UIActionSheetDelegate>

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.imagePicker.allowsEditing = self.allowsEditing;
        switch (self.sourceType) {
            case SourceTypeAll:
            {
                if (buttonIndex == 1) {
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self.viewController presentViewController:self.imagePicker animated:YES completion:nil];
                } else if (buttonIndex == 2) {
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    [self.viewController presentViewController:self.imagePicker animated:YES completion:nil];
                }
            }
                break;
            case SourceTypePhotoLibrary:
            {
                if (buttonIndex == 1) {
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    [self.viewController presentViewController:self.imagePicker animated:YES completion:nil];
                }
            }
                break;
            case SourceTypeCamera:
            {
                if (buttonIndex == 1) {
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self.viewController presentViewController:self.imagePicker animated:YES completion:nil];
                }
            }
                break;
                
            default:
                break;
        }
    }];
}

#pragma mark <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //@weakify(self); //弱化
    [picker dismissViewControllerAnimated:NO completion:^{
      //  @strongify(self);//强化
        UIImage *image = nil;
        if (picker.allowsEditing) {
            image = info[UIImagePickerControllerEditedImage];
        } else {
            image = info[UIImagePickerControllerOriginalImage];
        }
        NSData *imageData = UIImageJPEGRepresentation(image, 0.01);
        UIImage *compressedImage = [UIImage imageWithData:imageData];
        //二次压缩
//        while (imageData.length/1000 > 1024) {
//            imageData = UIImageJPEGRepresentation(image, 0.5);
//            compressedImage = [UIImage imageWithData:imageData];
//        }
        self.completionHandler(imageData, compressedImage);
        NSLog(@"kb = %ld",imageData.length/1000);
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - setters & getters

- (UIImagePickerController *)imagePicker
{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

@end
