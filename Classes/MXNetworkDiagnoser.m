//
//  MXNetworkDiagnoser.m
//  Example
//
//  Created by muyexi on 11/19/15.
//  Copyright © 2015 Jianshu. All rights reserved.
//

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#include <resolv.h>
#include <arpa/inet.h>

#import <GBPing/GBPing.h>
#import <IVYTraceroute/IVYTraceroute.h>
#import <SDVersion/SDVersion.h>

#import "MXNetworkDiagnoser.h"
#import "ALNetwork.h"
#import "ALJailbreak.h"

@interface MXNetworkDiagnoser () <GBPingDelegate>

@property (strong, nonatomic) GBPing *ping;

@property (strong, nonatomic) NSArray *domains;

@property (strong, nonatomic) NSString *userID;

@property (strong, nonatomic) NSMutableString *disgnoseLog;

@end

@implementation MXNetworkDiagnoser

- (instancetype)initWithUserID:(NSString *)userID domains:(NSArray *)domains {
    self = [super init];
    if (self) {
        self.userID = userID;
        self.domains = domains;
        
        self.disgnoseLog = [NSMutableString string];
        
        self.ping = [GBPing new];
        self.ping.delegate = self;
    }
    return self;
}

- (void)startDiagnose {
    if ([self.delegate respondsToSelector:@selector(startDiagnose)]) {
        [self.delegate startDiagnose];
    }
    
    [self addDiagnoseLogLine:@"开始诊断\n"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self recordBasicInfo];
        [self diagnoseDomain:self.domains.firstObject];
    });
}

- (void)stopDiagnose {
    [self addDiagnoseLogLine:@"\n结束诊断"];
    [[IVYTraceroute sharedTraceroute] stopTrace];
}

#pragma mark - GBPingDelegate
-(void)ping:(GBPing *)pinger didReceiveReplyWithSummary:(GBPingSummary *)summary {
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"REPLY> %@", summary]];
}

-(void)ping:(GBPing *)pinger didReceiveUnexpectedReplyWithSummary:(GBPingSummary *)summary {
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"BREPLY> %@", summary]];
}

-(void)ping:(GBPing *)pinger didTimeoutWithSummary:(GBPingSummary *)summary {
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"TIMOUT> %@", summary]];
}

-(void)ping:(GBPing *)pinger didFailWithError:(NSError *)error {
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"FAIL> %@", error]];
}

-(void)ping:(GBPing *)pinger didFailToSendPingWithSummary:(GBPingSummary *)summary error:(NSError *)error {
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"FSENT> %@, %@", summary, error]];
}

#pragma mark - Private Method
- (void)diagnoseDomain:(NSString *)domain {
    self.ping = [GBPing new];
    self.ping.delegate = self;
    self.ping.host = domain;
    
    [self.ping setupWithBlock:^(BOOL success, NSError *error) {
        if (success) {
            [self addDiagnoseLogLine:[NSString stringWithFormat:@"\nping: %@",domain]];
            [self.ping startPinging];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.ping stop];
                self.shouldTraceroute ? [self startTracerouteDomain:domain] : [self diagnoseNextDomain:domain];
            });
        } else {
            [self addDiagnoseLogLine:[NSString stringWithFormat:@"\nFailed to ping: %@", domain]];
            
            [self.ping stop];
            self.shouldTraceroute ? [self startTracerouteDomain:domain] : [self diagnoseNextDomain:domain];
        }
    }];
}

- (void)diagnoseNextDomain:(NSString *)domain {
    if ([domain isEqualToString:self.domains.lastObject]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(endDiagnoseWithLog:)]) {
                [self.delegate endDiagnoseWithLog:self.disgnoseLog];
            }
            
            [self stopDiagnose];
        });
    } else {
        NSUInteger index = [self.domains indexOfObject:domain];
        index ++;
        
        [self diagnoseDomain:[self.domains objectAtIndex:index]];
    }
}

- (void)startTracerouteDomain:(NSString *)domain {
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"\ntraceroute: %@",domain]];
    [self tracerouteDomain:domain];
}

- (void)tracerouteDomain:(NSString *)domain {
    [[IVYTraceroute sharedTraceroute] tracerouteToHost:domain
                                               process:^(IVYHop *routeHop, NSArray *hops) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [self addDiagnoseLogLine:routeHop.description];
                                                   });
                                                   
                                                   if (hops.count == 50 * 2) {
                                                       [[IVYTraceroute sharedTraceroute] stopTrace];
                                                   }
                                               }
                                               handler:^(BOOL success, NSArray *hops) {
                                                   [self diagnoseNextDomain:domain];
                                               }];
}

- (void)addDiagnoseLogLine:(NSString *)string {
    string = [string stringByAppendingString:@"\n"];
    
    [self.disgnoseLog appendString:string];
    
    if ([self.delegate respondsToSelector:@selector(addDiagnoseLogLine:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate addDiagnoseLogLine:string];
        });
    }
}

- (void)recordBasicInfo {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"时间：%@", dateString]];
    
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"用户id: %@", self.userID]];
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"应用名称: %@", appName]];
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"应用版本: %@", appVersion]];
    
    NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"Build版本: %@", buildVersion]];

    [self addDiagnoseLogLine:[NSString stringWithFormat:@"设备型号: %@", stringFromDeviceVersion([SDVersion deviceVersion])]];
    
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"是否越狱: %@", [ALJailbreak isJailbroken] ? @"YES" : @"NO"]];
    
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"系统版本: %@", [[UIDevice currentDevice] systemVersion]]];
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"GUID: %@", [[[UIDevice currentDevice] identifierForVendor] UUIDString]]];

    CTCarrier *carrier = [[CTTelephonyNetworkInfo new] subscriberCellularProvider];
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"运营商: %@", [carrier carrierName]]];
    
    if ([ALNetwork connectedViaWiFi]) {
        [self addDiagnoseLogLine:[NSString stringWithFormat:@"网络类型: WiFi"]];
    } else if ([ALNetwork connectedVia3G]){
        [self addDiagnoseLogLine:[NSString stringWithFormat:@"网络类型: 3G"]];
    }
    
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"本地IP: %@", [ALNetwork currentIPAddress]]];
    
    NSURL *url = [NSURL URLWithString:@"https://api.ipify.org/"];
    NSString *ipAddress = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"外网IP: %@", ipAddress]];
    
    [self addDiagnoseLogLine:[NSString stringWithFormat:@"DNS: %@", [MXNetworkDiagnoser getDNSServers]]];
}

+ (NSArray *)getDNSServers {
    res_state res = malloc(sizeof(struct __res_state));
    
    int result = res_ninit(res);
    NSMutableArray *servers = [[NSMutableArray alloc] init];
    if (result == 0) {
        for (int i = 0; i < res->nscount; i++) {
            NSString *s = [NSString stringWithUTF8String:inet_ntoa(res->nsaddr_list[i].sin_addr)];
            [servers addObject:s];
        }
    }
    
    return [NSArray arrayWithArray:servers];
}

@end
