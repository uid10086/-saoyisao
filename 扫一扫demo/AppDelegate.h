//
//  AppDelegate.h
//  扫一扫demo
//
//  Created by Alion on 16/12/28.
//  Copyright © 2016年 Alion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

