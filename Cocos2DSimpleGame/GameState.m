//
//  GameState.m
//  Cocos2DSimpleGame
//
//  Created by JIAYU ZENG on 7/1/15.
//  Copyright 2015 Razeware LLC. All rights reserved.
//

#import "GameState.h"


@implementation GameState

-(id) initWithBoxLocaton:(CGRect)loc andState:(NSInteger)tag{
    self->location = loc;
    self->state = tag;
    return self;
                         
}

- (CGRect)getLocation{ return self->location;}
- (void)setState:(NSInteger)tag {
    self->state = tag;
}
- (NSInteger)getState{
    return self->state;
}
@end
