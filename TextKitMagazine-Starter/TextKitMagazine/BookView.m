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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
    }
    return self;
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
        
//        UITextView *textView = [[UITextView alloc] initWithFrame:textViewRect textContainer:textContainer];
//        [self addSubview:textView];
        
        containterIndex++ ;
        range = [_layoutManager glyphRangeForTextContainer:textContainer];
    }
    
    self.contentSize = CGSizeMake((self.bounds.size.width / 2) * (CGFloat)containterIndex, self.bounds.size.height);
    self.pagingEnabled = YES;
    
    [self buildViewsForCurrentOffset];

}

- (CGRect) frameForViewAtIndex:(NSUInteger) index
{
    CGRect textViewRect = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
    textViewRect = CGRectInset(textViewRect, 10.0, 20.0);
    textViewRect = CGRectOffset(textViewRect, (self.bounds.size.width / 2 ) * (CGFloat)index, 0.0);
    return textViewRect;
}

// 获取为 textView 的子视图
- (NSArray *)textSubViews {
    NSMutableArray *views = [NSMutableArray new];
    for (UIView *subview in self.subviews)
    {
        if ([subview class] == [UITextView class])
        {
            [views addObject:subview];
        }
    }
    return views;
}

// 返回textContainer 的持有者textView
- (UITextView *)textViewForContainer:(NSTextContainer *)textContainer
{
    for (UITextView *textView in [self textSubViews])
    {
        if (textView.textContainer == textContainer)
        {
        return textView;
        }
    }
    return nil;
}

// 只渲染 前一页，当前页，后下一页。其他的都不渲染
- (BOOL)shouldRenderView:(CGRect)viewFrame {
    if (viewFrame.origin.x + viewFrame.size.width < (self.contentOffset.x - self.bounds.size.width))
        return NO;
    if (viewFrame.origin.x >
        (self.contentOffset.x + self.bounds.size.width * 2.0))
        return NO;
    
    return YES;
}


- (void)buildViewsForCurrentOffset {
    // 1
    for(NSUInteger index = 0; index < _layoutManager.textContainers.count; index++) {
        // 2
        NSTextContainer *textContainer = _layoutManager.textContainers[index];
        UITextView *textView = [self textViewForContainer:textContainer];
        // 3
        CGRect textViewRect = [self frameForViewAtIndex:index];
        if ([self shouldRenderView:textViewRect]) { // 4
            if (!textView)
            {
                NSLog(@"Adding view at index %u", index);
                UITextView* textView = [[UITextView alloc] initWithFrame:textViewRect
                                                           textContainer:textContainer];
                
                [self addSubview:textView];
            }
        }
        else
        { // 5
            if (textView)
            {
                NSLog(@"Deleting view at index %u", index);
                [textView removeFromSuperview];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self buildViewsForCurrentOffset];
}

@end

