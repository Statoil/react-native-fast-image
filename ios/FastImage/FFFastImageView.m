#import "FFFastImageView.h"

@implementation FFFastImageView

- (void)setIOSRefreshCached:(BOOL)iOSRefreshCached
{
    if (_iOSRefreshCached != iOSRefreshCached) {
        _iOSRefreshCached = iOSRefreshCached;

        [self updateImage];
    }
}

- (void)setIOSProgressiveDownload:(BOOL)iOSProgressiveDownload
{
    if (_iOSProgressiveDownload != iOSProgressiveDownload) {
        _iOSProgressiveDownload = iOSProgressiveDownload;

        [self updateImage];
    }
}

- (void)setResizeMode:(RCTResizeMode)resizeMode
{
    if (_resizeMode != resizeMode) {
        _resizeMode = resizeMode;
        self.contentMode = (UIViewContentMode)resizeMode;

        [self updateImage];
    }
}

- (void)updateImage {

    // Set priority.
    SDWebImageOptions options = 0;
    options |= SDWebImageRetryFailed;
    switch (_source.priority) {
        case FFFPriorityLow:
            options |= SDWebImageLowPriority;
            break;
        case FFFPriorityNormal:
            // Priority is normal by default.
            break;
        case FFFPriorityHigh:
            options |= SDWebImageHighPriority;
            break;
    }
    options |= SDWebImageRefreshCached;
    if (_iOSRefreshCached) {
        options |= SDWebImageRefreshCached;
    }

    if (_iOSProgressiveDownload) {
        options |= SDWebImageProgressiveDownload;
    }

    [self sd_setImageWithURL:_source.uri
            placeholderImage:nil
                     options:options
                   completed:^(UIImage *image,
                               NSError *error,
                               SDImageCacheType cacheType,
                               NSURL *imageURL) {
                       if (error) {
                           if (_onFastImageError) {
                               _onFastImageError(@{});
                           }
                       } else {
                           if (_onFastImageLoad) {
                               _onFastImageLoad(@{});
                           }
                       }
                   }];
}

- (void)setSource:(FFFastImageSource *)source {
    if (_source != source) {
        _source = source;
        // Set headers.
        [source.headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString* header, BOOL *stop) {
            [[SDWebImageDownloader sharedDownloader] setValue:header forHTTPHeaderField:key];
        }];

        [self updateImage];
    }
}

@end
