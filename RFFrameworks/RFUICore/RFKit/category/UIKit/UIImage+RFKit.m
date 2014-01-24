
#import "RFKit.h"
#import "UIImage+RFKit.h"

@implementation UIImage (RFKit)

+ (UIImage *)resourceName:(NSString *)PNGFileName{
	return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PNGFileName ofType:@"png"]];
}

+ (UIImage *)resourceName:(NSString *)fileName ofType:(NSString *)type {
	return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:type]];
}

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize {
    return [self imageAspectFillSize:targetSize];
}

//!ref: http://stackoverflow.com/a/605385/945906
- (UIImage *)imageAspectFillSize:(CGSize)targetSize{
	if (CGSizeEqualToSize(self.size, targetSize)) {
		return RF_AUTORELEASE([self copy]);
	}
	
	CGFloat xSource = self.size.width;
	CGFloat ySource = self.size.height;
	CGFloat xTarget = targetSize.width;
	CGFloat yTarget = targetSize.height;
	CGRect tmpImageRect = CGRectMake(0, 0, xSource, ySource);
	CGFloat factor;
	
	if (xSource/ySource > xTarget/yTarget) {
		// 图像按高适配
		factor = yTarget/ySource;
		tmpImageRect.size.width = xSource*factor;
		tmpImageRect.size.height = yTarget;
		tmpImageRect.origin.x = (xTarget -tmpImageRect.size.width)/2;
	}
	else {
		// 图像按宽度适配
		factor = xTarget/xSource;
		tmpImageRect.size.height = ySource*factor;
		tmpImageRect.size.width = xTarget;
		tmpImageRect.origin.y = (yTarget - tmpImageRect.size.height)/2;
	}
	
	UIGraphicsBeginImageContext(targetSize);
	[self drawInRect:tmpImageRect];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	if (!newImage) dout_error(@"Resize Image Faile");
	UIGraphicsEndImageContext();
	return newImage;
}

- (UIImage *)imageAspectFitSize:(CGSize)targetSize {
    if (CGSizeEqualToSize(self.size, targetSize)) {
		return RF_AUTORELEASE([self copy]);
	}
	
	CGFloat xSource = self.size.width;
	CGFloat ySource = self.size.height;
	CGFloat xTarget = targetSize.width;
	CGFloat yTarget = targetSize.height;
	CGRect tmpImageRect = CGRectMake(0, 0, xSource, ySource);
	CGFloat factor;
	
	if (xSource/ySource > xTarget/yTarget) {
        // 图像按宽度适配
        factor = xTarget/xSource;
        tmpImageRect.size.height = ySource*factor;
        tmpImageRect.size.width = xTarget;
        tmpImageRect.origin.y = (yTarget - tmpImageRect.size.height)/2;
	}
	else {
        // 图像按高适配
        factor = yTarget/ySource;
        tmpImageRect.size.width = xSource*factor;
        tmpImageRect.size.height = yTarget;
        tmpImageRect.origin.x = (xTarget -tmpImageRect.size.width)/2;
	}
	
	UIGraphicsBeginImageContext(targetSize);
	[self drawInRect:tmpImageRect];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	if (!newImage) dout_error(@"Resize Image Faile");
	UIGraphicsEndImageContext();
	return newImage;
}

double radians (double degrees) {return degrees * M_PI/180;}

+ (UIImage*)createIconWithImage:(UIImage*)src imageOrientation:(NSDictionary*)info
{
    UIImage *circle=[UIImage imageNamed:@"section_personal_circle@2x.png"];
    CGFloat width=circle.size.width;
    CGFloat height=circle.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), circle.CGImage);
    
    if (src.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, radians(90));
        CGContextTranslateCTM (context, 0, -height);
        
    } else if (src.imageOrientation == UIImageOrientationRight||src.imageOrientation == UIImageOrientationRightMirrored) {
        CGContextRotateCTM (context, radians(-90));
        CGContextTranslateCTM (context, -width, 0);
        
    } else if (src.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (src.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (context, width, height);
        CGContextRotateCTM (context, radians(-180.));
    }
    CGContextBeginPath(context);
    
    CGContextTranslateCTM (context, 4, 4);
    CGRect rect = CGRectMake(0, 0, width-7, height-7);
    CGContextAddEllipseInRect(context, rect);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, rect , src.CGImage);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
	UIImage *image = [UIImage imageWithCGImage:imageMasked];
	CGImageRelease(imageMasked);
    return image;
}

//!ref: http://stackoverflow.com/a/7704399/945906
- (UIImage *)imageWithCropRect:(CGRect)rect {
    CGFloat scale = self.scale;
    rect = CGRectMake(rect.origin.x*scale, rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

- (UIImage*)imageWithScaledSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:(CGRect){CGPointZero, newSize}];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    if (!newImage) dout_error(@"Resize Image Faile");
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageWithScale:(CGFloat)scale {
    CGSize newSize = CGSizeMake(self.size.width*scale, self.size.height*scale);
    return [self imageWithScaledSize:newSize];
}

@end
