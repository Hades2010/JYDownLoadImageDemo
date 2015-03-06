//
//  PhotoRecord.h
//  JYDownLoadImageDemo
//
//  Created by JinYong on 15-3-5.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface PhotoRecord : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, readonly) BOOL hasImage;
@property (nonatomic, getter=isFiltered) BOOL filtered;
@property (nonatomic, getter=isFailed) BOOL failed;
@end
