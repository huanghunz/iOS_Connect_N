//
//  GameStack.h
//  Connect4-Clone
//
//  Created by JIAYU ZENG on 7/2/15.
//  Copyright 2015 jz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameStack : NSObject {
    NSMutableArray *_stack;
    int count;
}

- (id)  init;
- (int) getCount;
- (id)  pop;
- (void)push:(id)item;



@end
