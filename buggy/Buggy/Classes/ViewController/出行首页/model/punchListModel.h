//
//  punchListModel.h
//  Buggy
//
//  Created by goat on 2018/11/12.
//  Copyright © 2018 ningwu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface punchListModel : NSObject

@property(nonatomic,copy) NSString *headerurl;
@property(nonatomic,copy) NSString *lastpunchtime;
@property(nonatomic,copy) NSString *nickname;
@property(nonatomic,copy) NSString *time_value;

@end

NS_ASSUME_NONNULL_END
