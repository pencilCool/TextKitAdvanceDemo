//
//  BookView.h
//  TextKitMagazine
//
//  Created by tangyuhua on 2017/5/5.
//  Copyright © 2017年 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewDelegate.h"
@interface BookView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, copy) NSAttributedString *bookMarkup;
- (void)buildFrames;
- (void)navigateToCharacterLocation:(NSUInteger)location;

@property (nonatomic, weak) id<BookViewDelegate> bookViewDelegate;
@end
