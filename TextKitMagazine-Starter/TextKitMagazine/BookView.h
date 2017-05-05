//
//  BookView.h
//  TextKitMagazine
//
//  Created by tangyuhua on 2017/5/5.
//  Copyright © 2017年 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookView : UIView

@property (nonatomic, copy) NSAttributedString *bookMarkup;
- (void)buildFrames;

@end
