//
//  MCSTNode.m
//  Cocos2DSimpleGame
//
//  Created by JIAYU ZENG on 6/25/15.
//  Copyright 2015 Razeware LLC. All rights reserved.
//

#import "MCSTNode.h"



@implementation MCSTNode

-(id)initWithGame: (GameBoard*)gameCopy{
    
    self->numVisited = 0;
    self->numWins    = 0;
    
    self->childrenNodes = nil;
    self->parentNode = nil;
    
    self->unTriedMoves = [[NSMutableArray alloc] init];
    unTriedMoves = [gameCopy getAvailableSlots];
    
    self->children = [[NSMutableArray alloc] init];
    //self->children = nil;
    
    self->whoJustMoved = [gameCopy isPlayerTurn] == player?opponment:player;
    self->move = nil;
    
    return self;
}

-(id)initWithKey:(NSString*)key andParent:(MCSTNode*)parent withGameContent:(GameBoard*)gameCopy{
    
    self->numVisited = 0;
    self->numWins    = 0;
    
    self->childrenNodes = nil;
    self->parentNode = parent;
    
   
    
    self->children = [[NSMutableArray alloc] init];
    //self->children = nil;
    
    self->whoJustMoved = [gameCopy isPlayerTurn] == player?opponment:player;
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


-(MCSTNode*) UCTSelectChild{
    
   // s = sorted(self.childNodes, key = lambda c: (float(c.wins)/float(c.visits)) + math.sqrt(2 * math.
    
    // log(float(self.visits) / float(c.visits))))
    //return s[-1]# a tuple
    
    float bestValue = -999999;
    MCSTNode *mostUrgent = nil;
    
    for (int i = 0; i < [self->children count]; i++){
        MCSTNode *child = [self->children objectAtIndex:i];
        float value = (float)child->numWins/ (float)child->numVisited +
                        sqrt(2 *    log   ( (float)(self->numVisited) / (float)child->numVisited) );
        
        if (bestValue < value){
            bestValue = value;
            mostUrgent = child;
        }
        
        
    }
    
    return mostUrgent;
    
    
    //return @"(0,0)";
}


-(void)addChild:(NSString*)key withGame:(GameBoard*)gameCopy{
    MCSTNode *newChild = [[MCSTNode alloc] initWithKey:key andParent:self withGameContent:gameCopy];
    [self->children addObject:newChild];
    [self->unTriedMoves removeObject:key];
    return;
}

-(MCSTNode*)getNewestChild{
    int lastIndex = [self->children count] - 1;
    MCSTNode *child = [[MCSTNode alloc] init];
    child = [self->children objectAtIndex:lastIndex];
    return child;
}
-(MCSTNode*)getChildByIndex:(int)index{
    return [self->children objectAtIndex:index];
    
}

-(void)updateSimScore:(float)eval{
    
    self->numVisited++;
    self->numWins += eval;
}

-(NSString*) runMCS:(GameBoard*) gameState{

    MCSTNode *rootNode = self;
    MCSTNode *curNode = nil;
    
    int iterations = 0;

    while( iterations < 100){
        curNode = rootNode;
        
        GameBoard *gameStateCopy = [[GameBoard alloc] makeGameCopy:gameState];
        NSMutableDictionary *gameBoard = [gameStateCopy getGameBoard];
        
        // Selection
        // find the most urgent kid from a given formula
        while ([curNode->unTriedMoves count] == 0 && [curNode->children count] != 0) {
            curNode = [self UCTSelectChild];
            CCSprite *targetSlot = gameBoard[curNode->move];
           
            [gameStateCopy applyAction:targetSlot];
        
            
        }
        
        // Expand
        // randomly pick a untried move.
        int numUnTried = [curNode->unTriedMoves count];
        if (numUnTried != 0){
            int randomIndex = arc4random_uniform(numUnTried);
            NSString *randomKey = [ curNode->unTriedMoves objectAtIndex:randomIndex];
            CCSprite *targetSlot = gameBoard[randomKey];
            
          
            [gameStateCopy applyAction:targetSlot];
            
            [ self addChild:randomKey withGame:gameStateCopy];
            
            
            curNode = [self getNewestChild];
        }
        
        // Simulation
        // simulate the game to update the number of visited and score of winning
        int depth = 5;
        NSMutableArray *availableSlots = [[NSMutableArray alloc] init];
        availableSlots = [gameStateCopy getAvailableSlots];
        
        while ( [availableSlots count] > 0 ){
            depth--;
            int randomIndex = arc4random_uniform([availableSlots count]);
            NSString *randomKey = [ availableSlots objectAtIndex:randomIndex];
            CCSprite *targetSlot = gameBoard[randomKey];
            [gameStateCopy applyAction:targetSlot];
           
            availableSlots = [gameStateCopy getAvailableSlots];

        }
        
        // Backpropagating
        while (curNode != nil){
            NSString *curKey = curNode->move;
            int x = [gameStateCopy getXFromKey:curKey];
            int y = [gameStateCopy getYFromKey:curKey];
            CCSprite *oneSlot = gameBoard[curKey];
            NSInteger slotTag = oneSlot.tag;
       
            float eval = [gameStateCopy evaluateState:x andY:y of:slotTag ];
            
            [curNode updateSimScore:eval];
            curNode = curNode->parentNode;
            
        }
        
        iterations++;
        
    }
    
    // choose the most visited
    float mostVisted = -99999;
    float childVisited = 0;
    MCSTNode *mostVistedChild = nil;
    for ( int i = 0;  i < [rootNode->children count]; i ++){
        MCSTNode *child = [rootNode->children objectAtIndex:i];
        childVisited = child->numVisited;
        
        if (mostVisted < childVisited){
            mostVisted = childVisited;
            mostVistedChild = child;
        }
        
    }
    
    return mostVistedChild->move;
}

//
-(void)startGame:(id)sender{
    //code goes here
}

-(void)dealloc{

    [self->childrenNodes release];
    self->childrenNodes = nil;
    [self->parentNode release];
    self->parentNode = nil;
    [self->unTriedMoves release];
    self->unTriedMoves = nil;
    
    [super dealloc];
}

@end
