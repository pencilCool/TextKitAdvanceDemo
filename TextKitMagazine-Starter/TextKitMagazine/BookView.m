//
//  BookView.m
//  TextKitMagazine
//
//  Created by tangyuhua on 2017/5/5.
//  Copyright © 2017年 Colin Eberhardt. All rights reserved.
//

#import "BookView.h"

@implementation BookView
{
    // layoutmanager 的重用就是将 text storage 中存储的字符变成渲染好的几何图案。
    NSLayoutManager *_layoutManager;
}

- (void)buildFrames
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self.bookMarkup];
    _layoutManager = [[NSLayoutManager alloc]init];
    [textStorage addLayoutManager:_layoutManager];
    
    NSTextContainer *textcontainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(self.bounds.size.width, FLT_MAX)];
    [_layoutManager addTextContainer:textcontainer];
    
    // create a view
    UITextView *textView = [[UITextView alloc] initWithFrame:self.bounds textContainer:textcontainer];
    textView.scrollEnabled = YES;
    [self addSubview:textView];
}
@end
