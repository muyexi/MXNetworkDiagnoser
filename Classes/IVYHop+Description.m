//
//  IVYHop+Description.m
//  Example
//
//  Created by muyexi on 11/21/15.
//  Copyright © 2015 Jianshu. All rights reserved.
//

#import "IVYHop+Description.h"

@implementation IVYHop (Description)

-(NSString*)description {
    return [NSString stringWithFormat:@"%i %@ %0.2f ms", self.ttl, self.hostAddress, self.elapsedTime * 1000];
}

@end
