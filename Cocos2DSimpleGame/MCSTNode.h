//
//  MCSTNode.h
//  Cocos2DSimpleGame
//
//  Created by JIAYU ZENG on 6/25/15.
//  Copyright 2015 Razeware LLC. All rights reserved.
//

#import "GameBoard.h"
#import <Foundation/Foundation.h>
#import "cocos2d.h"



@interface MCSTNode : CCNode {
    
    GameBoard *_gameStateCopy;
    NSMutableDictionary *_gameBoardCopy;
    int boardSize;
    int numVisited;
    int numWins;
    NSMutableArray *unTriedMoves;// store the empty slot
    NSString* parentKey;
    MCSTNode *childrenNodes;
}

-(id)initWithGame:(GameBoard*)game;

-(MCSTNode*) UCTSelectChild;


-(void)addChild:(MCSTNode *)child;

-(MCSTNode*)getChild:(MCSTNode*)parent;

-(void)updateSimScore:(int)wins and:(int)visited;

-(NSString*) runMCS;

-(int) getNumWins;
-(int) getNumVisited;


-(void)dealloc;





@end
