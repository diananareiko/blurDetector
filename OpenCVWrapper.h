#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
+ (double)varianceOfLaplacian:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
