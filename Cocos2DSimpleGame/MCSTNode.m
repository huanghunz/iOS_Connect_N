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
    self->numVisited = 1;
    self->numWins    = 100;
    self->childrenNodes = nil;
    self->parentKey = nil;
    
    return self;
}



@end
