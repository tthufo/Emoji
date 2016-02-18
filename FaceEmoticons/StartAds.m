//
//  StartAds.m
//  iosexampleapp
//
//  Created by thanhhaitran on 2/12/16.
//  Copyright © 2016 StartApp. All rights reserved.
//

#import "StartAds.h"

#import <StartApp/StartApp.h>

static StartAds * __shareVar;

@interface StartAds ()<STADelegateProtocol, STABannerDelegateProtocol>
{
    AdsCompletion compBanner, compFullBanner;
    
    STAStartAppAd *startAppAd_loadShow;
}
@end

@implementation StartAds

+ (StartAds *)sharedInstance
{
    if (!__shareVar)
    {
        __shareVar = [[StartAds alloc] init];
    }
    return __shareVar;
}

- (void)didShowBannerAdsWithInfor:(NSDictionary*)infor andCompletion:(AdsCompletion)completion
{
    compBanner = completion;
    
    STABannerView * startAppBanner_fixed = [[STABannerView alloc] initWithSize:STA_AutoAdSize
                                                        origin:CGPointMake(0,[infor[@"Y"] floatValue])
                                                      withView:((UIViewController*)infor[@"host"]).view withDelegate:self];
    
    [((UIViewController*)infor[@"host"]).view addSubview:startAppBanner_fixed];
}

- (void) didDisplayBannerAd:(STABannerView*)banner
{
    compBanner(AdsDone, nil, banner);
}

- (void) failedLoadBannerAd:(STABannerView*)banner withError:(NSError *)error
{
    compBanner(AdsFailed, error, banner);
}

- (void) didClickBannerAd:(STABannerView*)banner
{
    compBanner(AdsClicked, nil, banner);
}

- (void) didCloseBannerInAppStore:(STABannerView*)banner
{
    compBanner(AdsWillLeave, nil, banner);
}


#pragma FULLBANNER

- (void)didShowFullAdsWithInfor:(NSDictionary*)infor andCompletion:(AdsCompletion)completion
{
    compFullBanner = completion;
    
    startAppAd_loadShow = [[STAStartAppAd alloc] init];
    
    [startAppAd_loadShow loadAdWithDelegate:self];
}

- (void)didLoadAd:(STAAbstractAd*)ad;
{
    if (startAppAd_loadShow == ad)
    {
        [startAppAd_loadShow showAd];
        compFullBanner(AdsWillPresent, nil, ad);
    }
}

- (void) failedLoadAd:(STAAbstractAd*)ad withError:(NSError *)error;
{
    compFullBanner(AdsFailed, error, ad);
}

- (void)didShowAd:(STAAbstractAd*)ad;
{
    compFullBanner(AdsDone, nil, ad);
}

- (void) failedShowAd:(STAAbstractAd*)ad withError:(NSError *)error;
{
    if (startAppAd_loadShow == ad)
    {
        compFullBanner(AdsFailed, error, ad);
    }
}

- (void) didCloseAd:(STAAbstractAd*)ad
{
    if (startAppAd_loadShow == ad)
    {
        compFullBanner(AdsWillLeave, nil, ad);
    }
}


@end
