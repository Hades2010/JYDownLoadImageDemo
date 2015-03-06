//
//  ViewController.h
//  JYDownLoadImageDemo
//
//  Created by JinYong on 15-3-5.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoRecord.h"
#import "PendingOperations.h"
#import "ImageDownloader.h"
#import "ImageFiltration.h"

#import "AFNetworking/AFNetworking.h"

#define kDatasourceURLString @"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist"
@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,ImageDownloaderDelegate,ImageFiltrationDelegate>
//@property (nonatomic, strong) NSDictionary *photos;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) PendingOperations *pendingOperations;
@property (weak, nonatomic) IBOutlet UITableView *tableImages;

@end

