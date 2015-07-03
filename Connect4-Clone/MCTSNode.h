//
//  MCTSNode.h
//  Connect4-Clone
//
//  Created by JIAYU ZENG on 7/3/15.
//  Copyright 2015 jz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Game.h"

@interface MCTSNode : NSObject {
    
    NSString *move;
    
    int numVisited;
    float numWins;
    
    MCTSNode *parentNode;
    
    NSMutableArray *children;
    NSMutableArray *unTriedMoves;// store the empty slot
   }

-(id)initWithGame:(Game*)game;

-(MCTSNode*) UCTSelectChild;


-(void)addChild:(NSString*)key withGame:(Game*)gameCopy;

-(MCTSNode*)getNewestChild;

-(void)updateSimScore:(float)eval for:(NSInteger)playerJustMoved;

-(NSString*) runMCS:(Game*) gameState;

-(int) getNumWins;
-(int) getNumVisited;


-(void)dealloc;


@end
