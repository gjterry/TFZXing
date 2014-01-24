//
//  RFSegmentControl.m
//  TSA
//
//  Created by Terry  on 13-7-31.
//  Copyright (c) 2013年 ED. All rights reserved.
//

#import "RFSegmentControl.h"

@interface RFSegmentControl()

@end

@implementation RFSegmentControl

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setTitles:(NSArray *)titles {
    _titles = titles;
    [self itemWithTitles:titles];
}

- (void)setImages:(NSArray *)images {
    _images = images;
    [self itemWithImages:images];
}

-(void)setSelectedImages:(NSArray *)selectedImages {
    _selectedImages = selectedImages;
    [self itemWithSelectedImages:selectedImages];
}



- (void)itemWithImages:(NSArray *)itemImages {
    [[self subviews]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)obj;
            if (itemImages.count <=button.tag -1)
                return;
            [button setBackgroundImage:[UIImage imageNamed:itemImages[button.tag -1]] forState:UIControlStateNormal];
        }
    }];
}

- (void)itemWithSelectedImages:(NSArray *)itemSelectedImages {
    [[self subviews]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)obj;
            if (itemSelectedImages.count <=button.tag -1) 
                return;
            [button setBackgroundImage:[UIImage imageNamed:itemSelectedImages[button.tag -1]] forState:UIControlStateSelected];
        }
    }];
}



- (void)itemWithTitles:(NSArray *)itemTitles {
    [[self subviews]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)obj;
            if (itemTitles.count <=button.tag -1)
                return;
            [button setTitle:itemTitles[button.tag -1] forState:UIControlStateNormal];
            [button setTitle:itemTitles[button.tag -1] forState:UIControlStateSelected];
            if (self.nomarlColor && self.selectedColor) {
                [button setTitleColor:self.nomarlColor forState:UIControlStateNormal];
                [button setTitleColor:self.selectedColor forState:UIControlStateSelected];
            }
        }
    }];
}

- (IBAction)onSegmentChanged:(id)sender {
    [self setItemSelectedAtIndex:[sender tag]];
}

- (void)reset {
    [[self subviews]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[UIButton class]])
            [(UIButton *)obj setSelected:NO];
    }];
}

- (void)setItemSelectedAtIndex:(NSInteger)index {
    [self reset];
    if (index == 0) index = 1;  ///// 为了处理本身index为0的问题
    id obj = [self viewWithTag:index];
    if([obj isKindOfClass:[UIButton class]]) {
        [self bringSubviewToFront:obj];
        [(UIButton *)obj setSelected:YES];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(RFSegmenControl:itemChangedAtIndex:)]) {
        [self.delegate RFSegmenControl:self itemChangedAtIndex:index-1];
    }
}

@end
