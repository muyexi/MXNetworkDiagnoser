//
//  GBPingSummary+Description.m
//  Example
//
//  Created by muyexi on 11/21/15.
//  Copyright © 2015 Jianshu. All rights reserved.
//

#import "GBPingSummary+Description.h"

@implementation GBPingSummary (Description)

-(NSString *)description {
    NSString *description = [NSString stringWithFormat:@"%lu bytes from %@: icmp_seq=%lu ttl=%lu time=%0.2f ms",
                             self.payloadSize, self.host, self.sequenceNumber, self.ttl, self.rtt * 1000];
    return description;
}

@end
