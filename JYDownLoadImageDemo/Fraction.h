//
//  Fraction.h
//  JYDownLoadImageDemo
//
//  Created by JinYong on 15-3-6.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fraction : NSObject
{
    int numerator;
    int denomiator;
}
- (id)initWithNumeration:(int)a denominator:(int)b;
- (void)print;
@end
