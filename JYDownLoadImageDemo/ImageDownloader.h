//
//  ImageDownloader.h
//  JYDownLoadImageDemo
//
//  Created by JinYong on 15-3-5.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoRecord.h"

@protocol ImageDownloaderDelegate;

@interface ImageDownloader : NSOperation
@property (nonatomic, assign) id<ImageDownloaderDelegate> delegate;

@property (nonatomic, readonly, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readonly, strong) PhotoRecord *photoRecord;

- (id)initWithPhotoRecord:(PhotoRecord *)record anIndexPath:(NSIndexPath *)indexPath delegate:(id)theDelegate;
@end

@protocol ImageDownloaderDelegate
- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader;
@end