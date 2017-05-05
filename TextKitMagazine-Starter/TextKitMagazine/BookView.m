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
    
    
    // build the frames
    NSRange range = NSMakeRange(0, 0);
    NSUInteger containterIndex = 0;
    while (NSMaxRange(range) < _layoutManager.numberOfGlyphs) {
        CGRect textViewRect = [self frameForViewAtIndex:containterIndex];
        CGSize containerSize = CGSizeMake(textViewRect.size.width, textViewRect.size.height - 16.0f);
        NSTextContainer *textContainer =
        [[NSTextContainer alloc] initWithSize:containerSize];
        [_layoutManager addTextContainer:textContainer];
        
        UITextView *textView = [[UITextView alloc] initWithFrame:textViewRect textContainer:textContainer];
        [self addSubview:textView];
        
        containterIndex++ ;
        range = [_layoutManager glyphRangeForTextContainer:textContainer];
    }
    
    self.contentSize = CGSizeMake((self.bounds.size.width / 2) * (CGFloat)containterIndex, self.bounds.size.height);
    self.pagingEnabled = YES;
    
}

- (CGRect) frameForViewAtIndex:(NSUInteger) index
{
    CGRect textViewRect = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
    textViewRect = CGRectInset(textViewRect, 10.0, 20.0);
    textViewRect = CGRectOffset(textViewRect, (self.bounds.size.width / 2 ) * (CGFloat)index, 0.0);
    return textViewRect;
}


@end

