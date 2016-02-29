//
//  Ads.h
//  Pods
//
//  Created by thanhhaitran on 2/8/16.
//
//

#import <Foundation/Foundation.h>

typedef enum __bannerEvent
{
    AdsDone,
    AdsFailed,
    AdsWillPresent,
    AdsWillDismiss,
    AdsDidDismiss,
    AdsWillLeave,
    AdsClicked
}BannerEvent;

typedef void (^AdsCompletion)(BannerEvent event, NSError * error, id bannerAd);

@interface Ads : NSObject

+ (Ads *)sharedInstance;

- (void)G_didShowBannerAdsWithInfor:(NSDictionary*)infor andCompletion:(AdsCompletion)completion;

- (void)G_didShowFullAdsWithInfor:(NSDictionary*)infor andCompletion:(AdsCompletion)completion;

- (void)S_didShowBannerAdsWithInfor:(NSDictionary*)infor andCompletion:(AdsCompletion)completion;

- (void)S_didShowFullAdsWithInfor:(NSDictionary*)infor andCompletion:(AdsCompletion)completion;

@end
