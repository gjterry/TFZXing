//
//  RFSegmentControl.h
//  TSA
//
//  Created by Terry  on 13-7-31.
//  Copyright (c) 2013年 ED. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RFSegmentControlDelegate;

@interface RFSegmentControl : UIView
@property (nonatomic, assign) IBOutlet id <RFSegmentControlDelegate>delegate;

@property (nonatomic, retain) NSArray *titles;
@property (nonatomic, retain) NSArray *images;
@property (nonatomic, retain) NSArray *selectedImages;

@property (nonatomic, retain) UIColor *nomarlColor;
@property (nonatomic, retain) UIColor *selectedColor;


- (IBAction)onSegmentChanged:(id)sender;

- (void)setItemSelectedAtIndex:(NSInteger)index;
@end

@protocol RFSegmentControlDelegate <NSObject>

- (void)RFSegmenControl:(RFSegmentControl *)segment
     itemChangedAtIndex:(NSInteger)index;
@end