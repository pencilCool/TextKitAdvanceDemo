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
    NSRange _wordCharacterRange;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:recognizer];
        
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


- (void)navigateToCharacterLocation:(NSUInteger)location
{
    CGFloat offset = 0.0f;
    for (NSTextContainer *container in _layoutManager.textContainers)
    {
        NSRange glyphRange = [_layoutManager glyphRangeForTextContainer:container];
        NSRange charRange = [_layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:nil];
        if (location >= charRange.location && location < NSMaxRange(charRange)) {
            self.contentOffset = CGPointMake(offset, 0);
            return;
        }
        offset += self.bounds.size.width / 2.0f;
    }
  //  [self buildViewsForCurrentOffset];
}

- (void)handleTap: (UITapGestureRecognizer *)tapRecognizer
{
    NSTextStorage *textStorage = _layoutManager.textStorage;
    
    CGPoint tappedLocation = [tapRecognizer locationInView:self];
    
    UITextView *tappedTextView = nil;
    for (UITextView *textView in [self textSubViews]) {
        if (CGRectContainsPoint(textView.frame, tappedLocation)) {
            tappedTextView = textView;
            break;
        }
    }
    
    if (!tappedTextView) {
        return;
    }
    
    CGPoint subViewLocation = [tapRecognizer locationInView:tappedTextView];
    subViewLocation.y -= 8;
    
    
    NSUInteger glyphIndex = [_layoutManager glyphIndexForPoint:subViewLocation inTextContainer:tappedTextView.textContainer];
    NSUInteger charIndex = [_layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    
    if (![[NSCharacterSet letterCharacterSet] characterIsMember:[textStorage.string characterAtIndex:charIndex]]) {
        return;
    }
    
    _wordCharacterRange = [self wordThatContainsCharacter:charIndex
                                                   string:textStorage.string];
    [textStorage addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:_wordCharacterRange];
    
    
    
    
    // 1
    CGRect rect = [_layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:nil];
    
    // 2
    NSRange wordGlyphRange = [_layoutManager glyphRangeForCharacterRange:_wordCharacterRange actualCharacterRange:nil];
    CGPoint startLocation = [_layoutManager locationForGlyphAtIndex:wordGlyphRange.location];
    CGPoint endLocation   = [_layoutManager locationForGlyphAtIndex:NSMaxRange(wordGlyphRange)];
    
    
    // 3
    CGRect wordRect = CGRectMake(startLocation.x, rect.origin.y, endLocation.x - startLocation.x, rect.size.height);
    
    // 4
    wordRect = CGRectOffset(wordRect, tappedTextView.frame.origin.x, tappedTextView.frame.origin.y);
    
    // 5
    wordRect = CGRectOffset(wordRect, 0.0, 8.0);
    NSString *word = [textStorage.string substringWithRange:_wordCharacterRange];
    [self.bookViewDelegate bookView:self didHighlightWord:word inRect:wordRect];
}

// 获取点击位置的单词的开头和结尾
- (NSRange)wordThatContainsCharacter:(NSUInteger)charIndex string:(NSString *)string
{
    NSUInteger startLocation = charIndex;
    while(startLocation > 0 &&[[NSCharacterSet letterCharacterSet] characterIsMember: [string characterAtIndex:startLocation-1]]) {
        startLocation--;
    }
    NSUInteger endLocation = charIndex;
    while(endLocation < string.length && [[NSCharacterSet letterCharacterSet] characterIsMember: [string characterAtIndex:endLocation+1]]) {
        endLocation++; }
    return NSMakeRange(startLocation, endLocation-startLocation+1);
}





- (void)removeWordHighlight {
    [_layoutManager.textStorage removeAttribute:NSForegroundColorAttributeName
                                          range:_wordCharacterRange];
}









@end

