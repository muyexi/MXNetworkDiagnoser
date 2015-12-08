//
//  MXNetworkDiagnoser.h
//  Example
//
//  Created by muyexi on 11/19/15.
//  Copyright © 2015 Jianshu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MXNetworkDiagnoserDelegate <NSObject>

@optional

- (void)startDiagnose;

- (void)addDiagnoseLogLine:(NSString *)string;

- (void)endDiagnoseWithLog:(NSString *)string;

@end

@interface MXNetworkDiagnoser : NSObject

@property (weak, nonatomic) id<MXNetworkDiagnoserDelegate> delegate;
@property (assign, nonatomic) BOOL shouldTraceroute;

- (instancetype)initWithUserID:(NSString *)userID domains:(NSArray *)domains;

- (void)startDiagnose;

- (void)stopDiagnose;

@end
