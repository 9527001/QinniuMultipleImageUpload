//
//  QinniuMultipleImageUpload.m
//  QiniuDemo
//
//  Created by 赵东 on 2017/9/19.
//  Copyright © 2017年 Aaron. All rights reserved.
//

#import "QinniuMultipleImageUpload.h"

#import <UIKit/UIKit.h>
#import <QiniuSDK.h>

@interface QinniuMultipleImageUpload ()

@property (nonatomic,strong) NSString * token;
@property (nonatomic,strong) NSMutableArray  * dataArr;
@property (nonatomic,strong) NSArray  * photosdataArr;
@property (nonatomic,copy) QinniuMultipleImageUploadCallBack  callback;


@end

@implementation QinniuMultipleImageUpload

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static QinniuMultipleImageUpload * vc = nil;
    dispatch_once(&onceToken, ^{
        
        vc = [[QinniuMultipleImageUpload alloc] init];
    });
    return vc;
}

- (void)uploadMultipleImageWithImages:(NSArray * )arr token:(NSString * )token callback:(QinniuMultipleImageUploadCallBack)callback {
    
    if (!arr.count) {
        NSLog(@"请选择图片");
        return;
    }
    if (!token) {
        NSLog(@"请添加token");
        return;
    }
    
    self.token = token;
    self.photosdataArr = [arr mutableCopy];
    NSInteger counttmp = arr.count;
    self.dataArr = [NSMutableArray arrayWithCapacity:counttmp];
    for (NSInteger i = 0; i < counttmp; i ++) {
        [self.dataArr addObject:@""];
        UIImage * image = [arr objectAtIndex:i];
        [self uploadImageToQNFilePath:[self getImagePath:image] num:i];
    }
    self.callback = callback;
}

//上传功能代码
- (void)uploadImageToQNFilePath:(NSString *)filePath num:(NSInteger )num {
    
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        NSLog(@"percent == %.2f", percent);
    }
                                                                 params:@{@"x:label":[NSString stringWithFormat:@"%ld",num]}
                                                               checkCrc:NO
                                                     cancellationSignal:nil];
    
    [upManager putFile:filePath key:nil token:self.token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        NSLog(@"info ===== %@", info);
        NSLog(@"resp ===== %@", resp);
        
        //        count ++;
        NSString * hash = [resp objectForKey:@"hash"];
        //            NSString * keyTmp = [resp objectForKey:@"key"];
        NSString * xlabel = [resp objectForKey:@"x:label"];
//        [self.dataArr replaceObjectAtIndex:[xlabel integerValue] withObject:[NSString stringWithFormat:@"%@----%@",xlabel,hash]];
        [self.dataArr replaceObjectAtIndex:[xlabel integerValue] withObject:hash];
        
        if ([xlabel integerValue] + 1 == self.photosdataArr.count) {
            NSLog(@"game over");
            NSLog(@"%@",self.dataArr);
            if (self.callback ) {
                self.callback(self.dataArr);
            }
            return ;
        }
    }
                option:uploadOption];
}




//照片获取本地路径转换
- (NSString *)getImagePath:(UIImage *)Image {
    NSString *filePath = nil;
    NSData *data = nil;
    if (UIImagePNGRepresentation(Image) == nil) {
        data = UIImageJPEGRepresentation(Image, 1.0);
    } else {
        data = UIImagePNGRepresentation(Image);
    }
    
    //图片保存的路径
    //这里将图片放在沙盒的documents文件夹中
    NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //把刚刚图片转换的data对象拷贝至沙盒中
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *ImagePath = [[NSString alloc] initWithFormat:@"/theFirstImage.png"];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:ImagePath] contents:data attributes:nil];
    
    //得到选择后沙盒中图片的完整路径
    filePath = [[NSString alloc] initWithFormat:@"%@%@", DocumentsPath, ImagePath];
    return filePath;
}

@end
