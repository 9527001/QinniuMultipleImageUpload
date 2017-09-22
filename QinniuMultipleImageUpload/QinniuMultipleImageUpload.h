//
//  QinniuMultipleImageUpload.h
//  QiniuDemo
//
//  Created by 赵东 on 2017/9/19.
//  Copyright © 2017年 Aaron. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^QinniuMultipleImageUploadCallBack)(NSArray * hashArr);
@interface QinniuMultipleImageUpload : NSObject

//单例
+ (instancetype)shareManager;


/**
 多图上传

 @param arr 图片数组
 @param token 上传token qiniu生成
 */
- (void)uploadMultipleImageWithImages:(NSArray * )arr token:(NSString * )token callback:(QinniuMultipleImageUploadCallBack)callback ;

@end
