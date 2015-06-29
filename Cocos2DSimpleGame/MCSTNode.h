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
    
    
    NSString *move;
    
    int numVisited;
    int numWins;
    
    MCSTNode *parentNode;
    MCSTNode *childrenNodes;
    
    
    NSMutableArray *children;
    NSMutableArray *unTriedMoves;// store the empty slot
    NSInteger whoJustMoved;

}

-(id)initWithGame:(GameBoard*)game;

-(MCSTNode*) UCTSelectChild;


-(void)addChild:(NSString*)key withGame:(GameBoard*)gameCopy;

-(MCSTNode*)getNewestChild;

-(void)updateSimScore:(int)eval;

-(NSString*) runMCS:(GameBoard*) gameState;

-(int) getNumWins;
-(int) getNumVisited;


-(void)dealloc;





@end
