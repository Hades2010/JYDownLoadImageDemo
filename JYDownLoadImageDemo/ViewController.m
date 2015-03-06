//
//  ViewController.m
//  JYDownLoadImageDemo
//
//  Created by JinYong on 15-3-5.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "ViewController.h"
#import "Fraction.h"
#import "FractionChild.h"
@interface ViewController ()

@end

@implementation ViewController
//@synthesize photos = _photos;
@synthesize photos = _photos;
@synthesize pendingOperations = _pendingOperations;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.tableImages.dataSource = self;
    self.tableImages.delegate = self;
    self.tableImages.rowHeight = 80.0f;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
//    [self setPhotos:nil];
    [self setPendingOperations:nil];
    
    [self cancelAllOperation];
    
    // Dispose of any resources that can be recreated.
}

//- (void)testPosing{
//    Fraction *frac = [[Fraction alloc] initWithNumeration:3 denominator:4];
//    [frac print];//> Fraction: 3/4
//    
////    [FracitonChild poseAsClass [Fraction class]];
//    
//    Fraction *frac2 = [[Fraction alloc]initWithNumeration:3 denominator:4];
//    [frac2 print];//> FractionChild: 3/4
//}

#pragma mark - Lazy instantiation
- (PendingOperations *)pendingOperations {
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}

- (NSMutableArray *)photos {
    if (!_photos) {
        NSURL *datasoureURL = [NSURL URLWithString:kDatasourceURLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:datasoureURL];
        
        AFHTTPRequestOperation *datasource_download_operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [datasource_download_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSData *datasource_data = (NSData *)responseObject;
            CFPropertyListRef plist = CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (__bridge CFDataRef)datasource_data, kCFPropertyListImmutable, NULL);
            NSDictionary *datasource_dictionary = (__bridge NSDictionary *)plist;
            NSMutableArray *records = [NSMutableArray array];
            
            for (NSString *key in datasource_dictionary) {
                PhotoRecord *record = [[PhotoRecord alloc] init];
                record.URL = [NSURL URLWithString:[datasource_dictionary objectForKey:key]];
                record.name = key;
                [records addObject:record];
                record = nil;
            }
            
            self.photos = records;
            CFRelease(plist);
            
            [self.tableImages reloadData];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            alert = nil;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        
        [self.pendingOperations.downloadQueue addOperation:datasource_download_operation];
    }
    
    return _photos;
}


//- (NSDictionary *)photos {
//    if (!_photos) {
//        NSURL *dataSourceURL = [NSURL URLWithString:kDatasourceURLString];
//        _photos = [[NSDictionary alloc] initWithContentsOfURL:dataSourceURL];
//    }
//    return _photos;
//}

#pragma mark UITableView data source and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.photos.count;
    return count;
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = activityIndicatorView;
    }
    
    PhotoRecord *aRecord = [self.photos objectAtIndex:indexPath.row];
    
    if (aRecord.hasImage) {
        [(UIActivityIndicatorView *)cell.accessoryView stopAnimating];
        cell.imageView.image = aRecord.image;
        cell.textLabel.text = aRecord.name;
    } else if (aRecord.isFailed) {
        [(UIActivityIndicatorView *)cell.accessoryView stopAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Failed"];
        cell.textLabel.text = @"Failed to load";
    } else {
        [(UIActivityIndicatorView *)cell.accessoryView startAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Placeholder"];
        cell.textLabel.text = @"";
        
        if (!tableView.dragging && !tableView.decelerating) {
            [self startOperationsForPhotoRecord:aRecord anIndexPath:indexPath];
        }
    }
    
//    NSString *rowKey = [[self.photos allKeys] objectAtIndex:indexPath.row];
//    NSURL *imageURL = [NSURL URLWithString:[self.photos objectForKey:rowKey]];
//    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//    UIImage *image = nil;
//    if (imageData) {
//        UIImage *unfiltered_image = [UIImage imageWithData:imageData];
//        image = [self applySepiaFilterToImage:unfiltered_image];
//    }
//    
//    cell.textLabel.text = rowKey;
//    cell.imageView.image = image;
    
    return cell;
}

- (void)startOperationsForPhotoRecord:(PhotoRecord *)record anIndexPath:(NSIndexPath *)indexPath {
    if (!record.hasImage) {
        [self startImageDownloadingForRecord:record atIndexPath:indexPath];
    }
    
    if (!record.isFiltered) {
        [self startimageFiltrationForRecord:record anIndexPath:indexPath];
    }
}

- (void)startImageDownloadingForRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {
    if (![self.pendingOperations.downloadsInProgress.allKeys containsObject:indexPath]) {
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithPhotoRecord:record anIndexPath:indexPath delegate:self];
        [self.pendingOperations.downloadsInProgress setObject:imageDownloader forKey:indexPath];
        [self.pendingOperations.downloadQueue addOperation:imageDownloader];
    }
}


- (void)startimageFiltrationForRecord:(PhotoRecord *)record anIndexPath:(NSIndexPath *)indexPath {
    if (![self.pendingOperations.filtrationsInProgress.allKeys containsObject:indexPath]) {
        ImageFiltration *imageFiltration = [[ImageFiltration alloc] initWithPhotoRecord:record anIndexPath:indexPath delegate:self];
        ImageDownloader *dependency = [self.pendingOperations.downloadsInProgress objectForKey:indexPath];
        if (dependency) {
            [imageFiltration addDependency:dependency];
            
            [self.pendingOperations.filtrationsInProgress setObject:imageFiltration forKey:indexPath];
            [self.pendingOperations.filtrationQueue addOperation:imageFiltration];
        }
    }
}

#pragma mark Image Filter
- (UIImage *)applySepiaFilterToImage:(UIImage *)image {
    CIImage *inputImage = [CIImage imageWithData:UIImagePNGRepresentation(image)];
    UIImage *sepiaImage = nil;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey,inputImage,@"inputIntensity",[NSNumber numberWithFloat:0.8], nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef outputImageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];
    sepiaImage = [UIImage imageWithCGImage:outputImageRef];
    CGImageRelease(outputImageRef);
    return sepiaImage;
}

#pragma mark ImageDownloader ImageFiltration Delegate

- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {
    NSIndexPath *indexPath = downloader.indexPathInTableView;
//    PhotoRecord *theRecord = downloader.photoRecord;
    
    [self.tableImages reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
}

- (void)imageFiltrationDidFinish:(ImageFiltration *)filtration {
    NSIndexPath *indexPath = filtration.indexPathInTableView;
//    PhotoRecord *theRecord = filtration.photoRecord;
    
    [self.tableImages reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.pendingOperations.filtrationsInProgress removeObjectForKey:indexPath];
}

#pragma mark UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self suspendAllOperations];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadImagesForOnscreenCells];
        [self resumeAllOperations];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForOnscreenCells];
    [self resumeAllOperations];
}

#pragma mark Cancelling, supspending, resuming queue / operations
- (void)suspendAllOperations {
    [self.pendingOperations.downloadQueue setSuspended:YES];
    [self.pendingOperations.filtrationQueue setSuspended:YES];
}

- (void)resumeAllOperations {
    [self.pendingOperations.downloadQueue setSuspended:NO];
    [self.pendingOperations.filtrationQueue setSuspended:NO];
}

- (void)cancelAllOperation {
    [self.pendingOperations.downloadQueue cancelAllOperations];
    [self.pendingOperations.filtrationQueue cancelAllOperations];
}

- (void)loadImagesForOnscreenCells {
    NSSet *visibleRows = [NSSet setWithArray:[self.tableImages indexPathsForVisibleRows]];
    
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[self.pendingOperations.downloadsInProgress allKeys]];
    [pendingOperations addObjectsFromArray:[self.pendingOperations.filtrationsInProgress allKeys]];
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    NSMutableSet *toBeStarted = [visibleRows mutableCopy];
    
    [toBeStarted minusSet:pendingOperations];
    [toBeCancelled minusSet:visibleRows];
    
    for (NSIndexPath *anIndexPath in toBeCancelled) {
        ImageDownloader *pendingDownload = [self.pendingOperations.downloadsInProgress objectForKey:anIndexPath];
        [pendingDownload cancel];
        [self.pendingOperations.downloadsInProgress removeObjectForKey:anIndexPath];
        
        ImageFiltration *pendingFiltration = [self.pendingOperations.filtrationsInProgress objectForKey:anIndexPath];
        [pendingFiltration cancel];
        [self.pendingOperations.filtrationsInProgress removeObjectForKey:anIndexPath];
    }
    
    toBeCancelled = nil;
    
    for (NSIndexPath *anIndexPath in toBeStarted) {
        PhotoRecord *recordToProgress = [self.photos objectAtIndex:anIndexPath.row];
        [self startOperationsForPhotoRecord:recordToProgress anIndexPath:anIndexPath];
    }
    
    toBeStarted = nil;
}
@end
