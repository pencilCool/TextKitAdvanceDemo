//
//  MarkdownParser.m
//  TextKitMagazine
//
//  Created by tangyuhua on 2017/5/5.
//  Copyright © 2017年 Colin Eberhardt. All rights reserved.
//

#import "MarkdownParser.h"

@implementation MarkdownParser
{
    NSDictionary *_bodyTextAttributes;
    NSDictionary *_headingOneAttributes;
    NSDictionary *_headingTwoAttributes;
    NSDictionary *_headingThreeAttributes;
}

- (id)init {
    if (self = [super init]){
        [self createTextAttributes];
    }
    return self;
}

- (NSAttributedString *)parseMarkdownFile:(NSString *)path
{
    NSMutableAttributedString *parsedOutput = [[NSMutableAttributedString alloc]init];
    NSString *text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSUInteger lineIndex = 0; lineIndex < lines.count; lineIndex ++) {
        NSString *line = lines[lineIndex];
        if([line isEqualToString:@""]){
            continue;
        }
        NSDictionary *textAttributes = _bodyTextAttributes;
        if (line.length > 3) {
            if ([[line substringToIndex:3] isEqualToString:@"###"]) {
                textAttributes = _headingThreeAttributes;
                line = [line substringFromIndex:3];
            } else if ([[line substringToIndex:2] isEqualToString:@"##"]) {
                textAttributes = _headingTwoAttributes;
                line = [line substringFromIndex:2];
            } else if ([[line substringToIndex:1] isEqualToString:@"#"]) {
                textAttributes = _headingTwoAttributes;
                line = [line substringFromIndex:1];
            }
        }
        
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:line attributes:textAttributes];
        [parsedOutput appendAttributedString:attributedText];
        
        [parsedOutput appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\!\\[.*\\]\\((.*)\\)" options:0 error:nil];
    NSArray *matches = [regex matchesInString:[parsedOutput string] options:0 range:NSMakeRange(0, parsedOutput.length)];
    
    for (NSTextCheckingResult *result in [matches reverseObjectEnumerator]) {
        NSRange matchRange = [result range];
        NSRange captureRange = [result rangeAtIndex:1];
        
        NSTextAttachment *textAttachment = [NSTextAttachment new];
        textAttachment.image  = [UIImage imageNamed:[parsedOutput.string substringWithRange:captureRange]];
        NSAttributedString *replacementString = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [parsedOutput replaceCharactersInRange:matchRange withAttributedString:replacementString];
        
        
    }
    return parsedOutput;
}

- (void)createTextAttributes {
    UIFontDescriptor *baskerville = [UIFontDescriptor fontDescriptorWithFontAttributes:@{UIFontDescriptorFamilyAttribute: @"Baskerville"}];
    UIFontDescriptor *basekervilleBold = [baskerville fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    
    // 检测系统动态字体的大小，转化成UIFontDescriptor
    UIFontDescriptor *bodyFont = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    
    NSNumber *bodyFontSize = bodyFont.fontAttributes[UIFontDescriptorSizeAttribute];
    
    CGFloat bodyFontSizeValue = [bodyFontSize floatValue];
    
    _bodyTextAttributes = [self attributesWithDescriptor:baskerville size:bodyFontSizeValue];
    _headingOneAttributes = [self attributesWithDescriptor:basekervilleBold size:bodyFontSizeValue * 2.0f];
    _headingTwoAttributes = [self attributesWithDescriptor:basekervilleBold size:bodyFontSizeValue * 1.8];
    _headingThreeAttributes = [self attributesWithDescriptor:basekervilleBold size:bodyFontSizeValue * 1.4f];
    

}

- (NSDictionary *)attributesWithDescriptor:(UIFontDescriptor *)descriptor size:(CGFloat) size {
    UIFont *font = [UIFont fontWithDescriptor:descriptor size:size];
    return @{NSFontAttributeName: font};
}
@end
