#import "FFFastImageView.h"

@implementation FFFastImageView

- (void)setIOSRefreshCached:(BOOL)iOSRefreshCached
{
    if (_iOSRefreshCached != iOSRefreshCached) {
        _iOSRefreshCached = iOSRefreshCached;
    }
}

- (void)setIOSProgressiveDownload:(BOOL)iOSProgressiveDownload
{
    if (_iOSProgressiveDownload != iOSProgressiveDownload) {
        _iOSProgressiveDownload = iOSProgressiveDownload;
    }
}

- (void)setResizeMode:(RCTResizeMode)resizeMode
{
    if (_resizeMode != resizeMode) {
        _resizeMode = resizeMode;
        self.contentMode = (UIViewContentMode)resizeMode;
    }
}

- (void)setSource:(FFFastImageSource *)source {
    if (_source != source) {
        _source = source;
        // Set headers.
        [source.headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString* header, BOOL *stop) {
            [[SDWebImageDownloader sharedDownloader] setValue:header forHTTPHeaderField:key];
        }];

        // Set priority.
        SDWebImageOptions options = 0;
        options |= SDWebImageRetryFailed;
        switch (source.priority) {
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
/*
        if (_iOSRefreshCached) {
            options |= SDWebImageRefreshCached;
        }
        
        if (_iOSProgressiveDownload) {
            options |= SDWebImageProgressiveDownload;
        }*/
        
        // Load the new source.
        [self sd_setImageWithURL:source.uri
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
}

@end
