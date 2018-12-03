//
//  KVCHelper.m
//  CarCare
//
//  Created by ileo on 14-8-30.
//  Copyright (c) 2014年 baozun. All rights reserved.
//

#import "KVCHelper.h"

@interface KVCHelper()

@property (nonatomic, copy) void (^Change)(void);
@property (nonatomic, assign) id subject;
@property (nonatomic, copy) NSString *keyPath;

@end

@implementation KVCHelper

-(void)dealloc{
    [self.subject removeObserver:self forKeyPath:self.keyPath];
    self.Change = nil;
    self.subject = nil;
    self.keyPath = nil;
}

-(id)initWithSubject:(id)subject forKeyPath:(NSString *)keyPath change:(void (^)(void))change{
    self = [super init];
    if (self) {
        [subject addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        self.Change = change;
        self.subject = subject;
        self.keyPath = keyPath;
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([change[NSKeyValueChangeNewKey] isEqual:change[NSKeyValueChangeOldKey]]) {
        return;
    }
    self.Change();
}

@end
