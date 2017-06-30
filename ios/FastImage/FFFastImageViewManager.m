#import "FFFastImageViewManager.h"
#import "FFFastImageView.h"

#import <SDWebImage/SDWebImagePrefetcher.h>

@implementation FFFastImageViewManager

RCT_EXPORT_MODULE(FastImageView)

- (FFFastImageView*)view {
  FFFastImageView* view = [[FFFastImageView alloc] init];
  view.contentMode = (UIViewContentMode) RCTResizeModeContain;
  view.clipsToBounds = YES;
  return view;
}

RCT_EXPORT_VIEW_PROPERTY(source, FFFastImageSource);
RCT_EXPORT_VIEW_PROPERTY(resizeMode, RCTResizeMode);
RCT_EXPORT_VIEW_PROPERTY(onFastImageError, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFastImageLoad, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(iOSRefreshCached, BOOL);
RCT_EXPORT_VIEW_PROPERTY(iOSProgressiveDownload, BOOL);

RCT_EXPORT_METHOD(preload:(nonnull NSArray<FFFastImageSource *> *)sources)
{
    NSMutableArray *urls = [NSMutableArray arrayWithCapacity:sources.count];

    [sources enumerateObjectsUsingBlock:^(FFFastImageSource * _Nonnull source, NSUInteger idx, BOOL * _Nonnull stop) {
        [source.headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString* header, BOOL *stop) {
            [[SDWebImageDownloader sharedDownloader] setValue:header forHTTPHeaderField:key];
        }];
        [urls setObject:source.uri atIndexedSubscript:idx];
    }];
    
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:urls];
}

RCT_EXPORT_METHOD(clear)
{
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    @try {
        [imageCache clearMemory];
        [imageCache clearDiskOnCompletion:^{
            //resolve(@{});
        }];
    }
    @catch (NSException* e) {
        //reject(nil, nil, nil);
    }

}

@end

