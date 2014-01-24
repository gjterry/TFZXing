/*!
    RFButton
    RFUI
 
    ver -.-.-
 */

#import "RFUI.h"

@interface RFButton : UIView
@property (RF_WEAK, nonatomic) IBOutlet UIButton *agentButton;
@property (RF_WEAK, nonatomic) IBOutlet UIImageView *icon;
@property (RF_WEAK, nonatomic) IBOutlet UILabel *titleLabel;
@property (RF_WEAK, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (RF_WEAK, nonatomic) IBOutlet UIActivityIndicatorView *activitor;

- (void)setTappedBlock:(void (^)(RFButton *sender))onTappedBlock;
- (void)setTouchDownBlock:(void (^)(RFButton *sender))onTouchDownBlock;
- (void)setTouchUpBlock:(void (^)(RFButton *sender))onTouchUpBlock;


//把以下方法公开
- (void)setup;
- (void)onTouchDown;
- (void)onTouchUp;
- (void)highlight;
- (void)unhighlight;
@end
