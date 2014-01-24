
#import "RFButton.h"

@interface RFButton ()
@property (copy, nonatomic, setter = setTappedBlock:) void (^onTappedBlock)(RFButton *);
@property (copy, nonatomic, setter = setTouchDownBlock:) void (^onTouchDownBlock)(RFButton *);
@property (copy, nonatomic, setter = setTouchUpBlock:) void (^onTouchUpBlock)(RFButton *);
@end

@implementation RFButton

- (UIButton *)agentButton {
    if (!_agentButton) {
        UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        aButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
#pragma mark 暂时改动了RFButton 
        _agentButton = aButton;
        [self addSubview:self.agentButton resizeOption:RFViewResizeOptionFill];
        [self setup];

    }
    return _agentButton;
}


- (void)setup {
    [self.agentButton addTarget:self action:@selector(onTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.agentButton addTarget:self action:@selector(onTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.agentButton addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchUpOutside];
    [self.agentButton addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchCancel];
}
- (void)awakeFromNib {
    [self setup];
}

- (void)highlight {
    self.titleLabel.highlighted = YES;
    self.agentButton.highlighted = YES;
    self.backgroundImageView.highlighted = YES;
    if (self.onTouchDownBlock) {
        self.onTouchDownBlock(self);
    }
}
- (void)unhighlight {
    self.titleLabel.highlighted = NO;
    self.agentButton.highlighted = NO;
    self.backgroundImageView.highlighted = NO;
    if (self.onTouchUpBlock) {
        self.onTouchUpBlock(self);
    }
}

- (void)onTouchDown {
    [self highlight];
}
- (void)onTouchUp {
    [self unhighlight];
}
- (void)onTouchUpInside {
    if (self.onTappedBlock) {
        self.onTappedBlock(self);
    }
    
    __weak __typeof__(self) selfRef = self;
    [NSObject performBlock:^{
        [selfRef unhighlight];
    } afterDelay:0.1f];
}

@end
