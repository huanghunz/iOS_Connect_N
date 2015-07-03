//
//  GameStack.m
//  Cocos2DSimpleGame
//
//  Created by JIAYU ZENG on 7/2/15.
//  Copyright 2015 Razeware LLC. All rights reserved.
//

#import "GameStack.h"


@implementation GameStack

-(id) init{
    _stack = [[NSMutableArray alloc] init];
    count = 0;
    
    return self;
}

-(int)getCount { return count;}

-(id)pop{
    id lastItem = [_stack lastObject];
    [ _stack removeLastObject];
    return lastItem;
}

-(void)push:(id)item{
    [_stack addObject:item];
    count++;
}

@end
