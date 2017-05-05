//
//  BookViewDelegate.h
//  TextKitMagazine
//
//  Created by tangyuhua on 2017/5/5.
//  Copyright © 2017年 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BookView;
@protocol BookViewDelegate <NSObject>

- (void)bookView:(BookView *)bookView didHighlightWord:(NSString *)word inRect:(CGRect)rect;


@end
