//
//  AYInstructionsViewModel.h
//  Buggy
//
//  Created by goat on 2017/8/11.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AYInstructionsModel : NSObject
@property (nonatomic,strong) NSString *function; /**<类型 s 使用说明 c 常见问题*/
@property (nonatomic,strong) NSString *company;  /**<公司*/
@property (nonatomic,strong) AVFile   *instruction_File; /**<文件*/
@end
