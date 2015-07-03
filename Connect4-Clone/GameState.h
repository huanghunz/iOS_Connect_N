//
//  GameState.h
//  Connect4-Clone
//
//  Created by JIAYU ZENG on 7/2/15.
//  Copyright 2015 jz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// GameState -- one slot on the board
@interface GameState : NSObject {
    CGRect location;
    NSInteger state;
    
}

- (id)initWithBoxLocaton:(CGRect)size andState:(NSInteger)tag;

- (CGRect)  getLocation;
- (void)    setState:(NSInteger)tag;
- (NSInteger)getState;


@end
