//
//  GameState.h
//  Cocos2DSimpleGame
//
//  Created by JIAYU ZENG on 7/1/15.
//  Copyright 2015 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameState : CCNode {
    CGRect location;
    NSInteger state;
    
}

- (id)initWithBoxLocaton:(CGRect)size andState:(NSInteger)tag;

- (CGRect)getLocation;
- (void)setState:(NSInteger)tag;
- (NSInteger)getState;


@end
