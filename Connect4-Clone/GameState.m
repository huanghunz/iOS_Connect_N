//
//  GameState.m
//  Connect4-Clone
//
//  Created by JIAYU ZENG on 7/2/15.
//  Copyright 2015 jz. All rights reserved.
//

#import "GameState.h"


@implementation GameState

/* ==========  initWithBoxLocaton:(CGRect)loc andState:(NSInteger)tag =================
 Init the states of one slot
 pre:    loc --- defines bounding box location
         tag --- state of the slot (empty, belongs to human player or AI player
 post:   slot state initliazed, returns itself
 */
-(id) initWithBoxLocaton:(CGRect)loc andState:(NSInteger)tag{
    self->location = loc;
    self->state = tag;
    return self;
}

- (CGRect)getLocation{
    return self->location;
}

- (void)setState:(NSInteger)tag {
    self->state = tag;
}

- (NSInteger)getState{
    return self->state;
}
@end
