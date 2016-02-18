//
//  StartAds.h
//  iosexampleapp
//
//  Created by thanhhaitran on 2/12/16.
//  Copyright © 2016 StartApp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum __bannerEvent
{
    AdsDone,
    AdsFailed,
    AdsWillPresent,
    AdsWillLeave,
    AdsClicked
}BannerEvent;

typedef void (^AdsCompletion)(BannerEvent event, NSError * error, id bannerAd);

@interface StartAds : NSObject

+ (StartAds *)sharedInstance;

- (void)didShowBannerAdsWithInfor:(NSDictionary*)infor andCompletion:(AdsCompletion)completion;

- (void)didShowFullAdsWithInfor:(NSDictionary*)infor andCompletion:(AdsCompletion)completion;

@end
