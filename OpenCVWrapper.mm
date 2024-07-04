#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVWrapper.h"

/*
 * add a method convertToMat to UIImage class
 */
@interface UIImage (OpenCVWrapper)
- (void)convertToMat: (cv::Mat *)pMat: (bool)alphaExists;
@end

@implementation UIImage (OpenCVWrapper)

- (void)convertToMat: (cv::Mat *)pMat: (bool)alphaExists {
    if (self.imageOrientation == UIImageOrientationRight) {
        /*
         * When taking picture in portrait orientation,
         * convert UIImage to OpenCV Matrix in landscape right-side-up orientation,
         * and then rotate OpenCV Matrix to portrait orientation
         */
        UIImageToMat([UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUp], *pMat, alphaExists);
        cv::rotate(*pMat, *pMat, cv::ROTATE_90_CLOCKWISE);
    } else if (self.imageOrientation == UIImageOrientationLeft) {
        /*
         * When taking picture in portrait upside-down orientation,
         * convert UIImage to OpenCV Matrix in landscape right-side-up orientation,
         * and then rotate OpenCV Matrix to portrait upside-down orientation
         */
        UIImageToMat([UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUp], *pMat, alphaExists);
        cv::rotate(*pMat, *pMat, cv::ROTATE_90_COUNTERCLOCKWISE);
    } else {
        /*
         * When taking picture in landscape orientation,
         * convert UIImage to OpenCV Matrix directly,
         * and then ONLY rotate OpenCV Matrix for landscape left-side-up orientation
         */
        UIImageToMat(self, *pMat, alphaExists);
        if (self.imageOrientation == UIImageOrientationDown) {
            cv::rotate(*pMat, *pMat, cv::ROTATE_180);
        }
    }
}
@end

@implementation OpenCVWrapper

+ (double)varianceOfLaplacian:(UIImage *)image {
    cv::Mat mat;
    UIImageToMat(image, mat, false);

    if (mat.empty()) {
        // Handle error: image data is empty
        NSLog(@"Error: Image data is empty.");
        return -1;
    }

    cv::Mat gray;
    if (mat.channels() > 1) {
        cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY);
    } else {
        gray = mat;
    }

    // Increase contrast and brightness
    cv::Mat contrasted;
    double alpha = 1.5; // Simple contrast control [1.0-3.0]
    int beta = 0;      // Simple brightness control [0-100]
    gray.convertTo(contrasted, -1, alpha, beta);

    // Apply median blur to the enhanced image
    cv::Mat blurred;
    const int MEDIAN_BLUR_FILTER_SIZE = 15; // odd number
    cv::medianBlur(contrasted, blurred, MEDIAN_BLUR_FILTER_SIZE);

    // Compute the Laplacian of the blurred image
    cv::Mat laplacian;
    cv::Laplacian(blurred, laplacian, CV_64F);
    cv::Scalar mean, stddev;
    cv::meanStdDev(laplacian, mean, stddev);

    // Return the variance (standard deviation squared)
    return stddev.val[0] * stddev.val[0];
}

@end
