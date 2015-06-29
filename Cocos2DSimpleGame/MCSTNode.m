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

-(void)updateSimScore:(int)eval{
    
    self->numVisited++;
    self->numWins += eval;
}

-(NSString*) runMCS:(GameBoard*) gameState{
   // NSString *chosenKey = nil;
  
    MCSTNode *rootNode = self;
    MCSTNode *curNode = nil;
    
//    t_start = time.time()
//    t_now = time.time()
//    t_deadline = t_now + THINK_DURATION;
    int iterations = 0;
    
    while( iterations < 1000){
        curNode = rootNode;
        
        GameBoard *gameStateCopy = [[GameBoard alloc] makeGameCopy:gameState];
        NSMutableDictionary *gameBoard = [[gameStateCopy getGameBoard] mutableCopy];
        
        // Selection
        while ([curNode->unTriedMoves count] == 0 && [curNode->children count] != 0) {
            curNode = [self UCTSelectChild];
            CCSprite *targetSlot = gameBoard[(curNode->move)];
           
            [gameStateCopy applyAction:targetSlot];
        
            
        }
        
        // Expand
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
        int depth = 5;
        NSMutableArray *availableSlots = [[NSMutableArray alloc] init];
        availableSlots = [gameStateCopy getAvailableSlots];
        
        while ( [availableSlots count] > 0 && depth > 0){
            depth--;
            int randomIndex = arc4random_uniform(numUnTried);
            NSString *randomKey = [ availableSlots objectAtIndex:randomIndex];
            CCSprite *targetSlot = gameBoard[randomKey];
            [gameStateCopy applyAction:targetSlot];
           
            availableSlots = [gameStateCopy getAvailableSlots];

        }
        
        // Backpropagating
//        while node != None: # backpropagate from the expanded node and work back to the root node
//            print score, " == "
//            result = opponentScore(score, node.playerJustMoved)# evaluate the states
//            node.Update(result)
//            node = node.parentNode
        while (curNode != nil){
            NSString *curKey = curNode->move;
            int x = [gameStateCopy getXFromKey:curKey];
            int y = [gameStateCopy getYFromKey:curKey];
            CCSprite *oneSlot = gameBoard[curKey];
            NSInteger slotTag = oneSlot.tag;
            int eval = [gameStateCopy evaluateState:x andY:y of:slotTag ];
            
            [curNode updateSimScore:eval];
            curNode = curNode->parentNode;
            
        }
        
        iterations++;
        
    }
    
    //return sorted(rootnode.childNodes, key = lambda c: c.visits)[-1].move # return the move that was most visited
   
    // choose the most visited
    int mostVisted = -99999;
    int childVisited = 0;
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
