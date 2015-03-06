//
//  ImageFiltration.h
//  JYDownLoadImageDemo
//
//  Created by JinYong on 15-3-5.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoRecord.h"

@protocol ImageFiltrationDelegate;

@interface ImageFiltration : NSOperation
@property (nonatomic, weak) id delegate;
@property (nonatomic, readonly, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readonly, strong) PhotoRecord *photoRecord;

- (id)initWithPhotoRecord:(PhotoRecord *)record anIndexPath:(NSIndexPath *)indexPath delegate:(id)theDelegate;
@end

@protocol ImageFiltrationDelegate
- (void)imageFiltrationDidFinish:(ImageFiltration *)filtration;

@end