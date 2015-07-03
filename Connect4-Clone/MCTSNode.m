//
//  MCTSNode.m
//  Connect4-Clone
//
//  Created by JIAYU ZENG on 7/3/15.
//  Copyright 2015 jz. All rights reserved.
//
#import "MCTSNode.h"



@implementation MCTSNode

-(id)initWithGame: (Game*)gameCopy{
    
    self->numVisited = 0;
    self->numWins    = 0;
    
    self->parentNode = nil;
    
    self->unTriedMoves = [[NSMutableArray alloc] init];
    unTriedMoves = [gameCopy getAvailableSlots];
    
    self->children = [[NSMutableArray alloc] init];
   
    self->move = nil;
    
    return self;
}

-(id)initWithKey:(NSString*)key andParent:(MCTSNode*)parent withGameContent:(Game*)gameCopy{
    
    self->numVisited = 0;
    self->numWins    = 0;
    
    self->parentNode = parent;
    
    self->children = [[NSMutableArray alloc] init];
    
    self->move = [[NSString alloc] init];
    self->move = key;
    
    return self;
    
    
}

-(int)getNumWins{
    return self->numWins;
}
-(int)getNumVisited{
    return self->numVisited;
}


-(MCTSNode*) UCTSelectChild{
    
    float bestValue = -999999;
    MCTSNode *mostUrgent = nil;
    
    for (int i = 0; i < [self->children count]; i++){
        MCTSNode *child = [self->children objectAtIndex:i];
        float value = (float)child->numWins/ (float)child->numVisited +
        sqrt(2 *    log   ( (float)(self->numVisited) / (float)child->numVisited) );
        
        if (bestValue < value){
            bestValue = value;
            mostUrgent = child;
        }
        
        
    }
    
    return mostUrgent;
    
}


-(void)addChild:(NSString*)key withGame:(Game*)gameCopy{
    MCTSNode *newChild = [[MCTSNode alloc] initWithKey:key andParent:self withGameContent:gameCopy];
    [self->children addObject:newChild];
    [self->unTriedMoves removeObject:key];
    return;
}

-(MCTSNode*)getNewestChild{
   
  // = [[MCTSNode alloc] init];
    MCTSNode * child = [self->children lastObject];
    return child;
}


-(void)updateSimScore:(float)eval for:(NSInteger)playerJustMoved{
    
    self->numVisited++;
    if (playerJustMoved == player)
        self->numWins -= eval;
    else
        self->numWins += eval;
}

-(NSString*) runMCS:(Game*) gameState{
    
    MCTSNode *rootNode = self;
    MCTSNode *curNode = nil;
    
    int iterations = 0;
    
    while( iterations < 100){
        curNode = rootNode;
        
        Game *gameStateCopy = [[Game alloc] makeGameCopy:gameState];
        
        NSMutableDictionary *gameBoard = [gameStateCopy getGameBoard];
        
        // Selection
        // find the most urgent kid from a given formula
        // it won't run for the first round
        while ([curNode->unTriedMoves count] == 0 && [curNode->children count] != 0) {
            curNode = [self UCTSelectChild];
            GameState *targetSlot = gameBoard[curNode->move];
            
            [gameStateCopy applyAction:targetSlot];
            
            
        }
        
        // Expand
        // randomly pick a untried move.
        int numUnTried = [curNode->unTriedMoves count];
        if (numUnTried != 0){
            int randomIndex = arc4random_uniform(numUnTried);
            NSString *randomKey = [ curNode->unTriedMoves objectAtIndex:randomIndex];
            GameState *targetSlot = gameBoard[randomKey];
            
            
            [gameStateCopy applyAction:targetSlot];
            
            [ self addChild:randomKey withGame:gameStateCopy];
            
            
            curNode = [self getNewestChild];
        }
        
        // Simulation
        // simulate the game to update the number of visited and score of winning
        NSMutableArray *availableSlots = [[NSMutableArray alloc] init];
        availableSlots = [gameStateCopy getAvailableSlots];
        
        while ( [availableSlots count] > 0 ){
           
            int randomIndex = arc4random_uniform([availableSlots count]);
            NSString *randomKey = [ availableSlots objectAtIndex:randomIndex];
            GameState *targetSlot = gameBoard[randomKey];
            [gameStateCopy applyAction:targetSlot];
            
            [availableSlots release];
            availableSlots = [gameStateCopy getAvailableSlots];
            
        }
        
        int x, y;
        // Backpropagating
        while (curNode != nil){
            NSString *curKey = curNode->move;
            [gameStateCopy getX:&x andY:&y fromKey:curKey];
            GameState *oneSlot = gameBoard[curKey];
            
            float eval = [gameStateCopy evaluateState:x andY:y of:[oneSlot getState] ];
            
            NSInteger playerJustMoved = ([gameStateCopy isPlayerTurn])?opponment:player;
    
            [curNode updateSimScore:eval for:playerJustMoved];
            curNode = curNode->parentNode;
        }
        
        [gameStateCopy release];
        
        iterations++;
        
    }
    
    // choose the most visited
    float mostVisted = -99999;
    float childVisited = 0;
    MCTSNode *mostVistedChild = nil;
    for ( int i = 0;  i < [rootNode->children count]; i ++){
        MCTSNode *child = [rootNode->children objectAtIndex:i];
        childVisited = child->numWins;
        
        if (mostVisted < childVisited){
            mostVisted = childVisited;
            mostVistedChild = child;
        }
        
    }
    
    return mostVistedChild->move;
}


-(void)dealloc{
    
    [self->parentNode release];
    self->parentNode = nil;
    [self->unTriedMoves release];
    self->unTriedMoves = nil;
    
    [super dealloc];
}

@end
