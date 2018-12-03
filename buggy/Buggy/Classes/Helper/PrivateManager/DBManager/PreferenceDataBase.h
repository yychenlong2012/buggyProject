//
//  PreferenceDataBase.h
//  Buggy
//
//  Created by 孟德林 on 2017/5/12.
//  Copyright © 2017年 ningwu. All rights reserved.
//

#import "DataBaseEngine.h"

@interface PreferenceDataBase : DataBaseEngine

- (NSInteger )numberOfPerference;

- (BOOL)isExistOfPerference:(NSDictionary *)data;

@end
