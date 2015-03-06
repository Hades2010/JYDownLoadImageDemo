//
//  ImageFiltration.m
//  JYDownLoadImageDemo
//
//  Created by JinYong on 15-3-5.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "ImageFiltration.h"

@interface ImageFiltration()
@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) PhotoRecord *photoRecord;
@end

@implementation ImageFiltration
@synthesize indexPathInTableView = _indexPathInTableView;
@synthesize photoRecord = _photoRecord;
@synthesize delegate = _delegate;

#pragma mark Life cycle
- (id)initWithPhotoRecord:(PhotoRecord *)record anIndexPath:(NSIndexPath *)indexPath delegate:(id)theDelegate {
    if (self = [super init]) {
        self.photoRecord = record;
        self.indexPathInTableView = indexPath;
        self.delegate = theDelegate;
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        if (self.isCancelled) return;
        
        if (!self.photoRecord.hasImage) return;
        
        UIImage *rawImage = self.photoRecord.image;
        UIImage *processedImage = [self applySepiaFilterToImage:rawImage];
        
        if (self.isCancelled) return;
        if (processedImage) {
            self.photoRecord.image = processedImage;
            self.photoRecord.filtered = YES;
            
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageFiltrationDidFinish:) withObject:self waitUntilDone:NO];
        }
    }
}

#pragma mark Filtering image
- (UIImage *)applySepiaFilterToImage:(UIImage *)image {
    CIImage *inputImage = [CIImage imageWithData:UIImagePNGRepresentation(image)];
    
    if (self.isCancelled) return nil;
    
    UIImage *sepiaImage = nil;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues: kCIInputImageKey, inputImage, @"inputIntensity", [NSNumber numberWithFloat:0.8], nil];
    CIImage *outputImage = [filter outputImage];
    
    if (self.isCancelled) return nil;
    
    CGImageRef outputImageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    if (self.isCancelled) {
        CGImageRelease(outputImageRef);
        return nil;
    }
    
    sepiaImage = [UIImage imageWithCGImage:outputImageRef];
    CGImageRelease(outputImageRef);
    return sepiaImage;
}
@end
