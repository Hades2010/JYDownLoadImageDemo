//
//  Fraction.m
//  JYDownLoadImageDemo
//
//  Created by JinYong on 15-3-6.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "Fraction.h"

@implementation Fraction
- (id)initWithNumeration:(int)a denominator:(int)b {
    self = [super init];
    if (self) {
        numerator = a;
        denomiator = b;
    }
    return self;
}

- (void)print {
    NSLog(@"Fraction : %d %d",numerator,denomiator);
}
@end
