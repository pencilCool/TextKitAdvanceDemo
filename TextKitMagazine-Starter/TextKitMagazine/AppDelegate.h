//
//  AppDelegate.h
//  TextKitMagazine
//
//  Created by Colin Eberhardt on 02/07/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//This property will store the book markup and formatting in an attributed string.
@property (nonatomic, copy) NSAttributedString *bookMarkup;

@property (nonatomic, strong) NSArray *chapters;

@end
