//
//  MCSTNode.m
//  Cocos2DSimpleGame
//
//  Created by JIAYU ZENG on 6/25/15.
//  Copyright 2015 Razeware LLC. All rights reserved.
//

#import "MCSTNode.h"


@implementation MCSTNode

-(id)init: (NSMutableDictionary*)gameBoard{
    self->_gameBoardCopy = [gameBoard mutableCopy];
    self->numVisited = 0;
    self->numWins    = 0;
    self->childrenNodes = nil;
    self->parentKey = nil;
    self->unTriedMoves = [NSMutableArray alloc];
    
    int col = 0;
    int row = 0;
    
    return self;
}

-(int)getNumWins{
    return self->numWins;
}
-(int)getNumVisited{
    return self->numVisited;
}

@end
