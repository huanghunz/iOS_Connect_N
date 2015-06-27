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
    
    self->_gameStateCopy = gameCopy;
    self->_gameBoardCopy = [[_gameStateCopy getGameBoard] mutableCopy];
    self->boardSize = [gameCopy getBoardSize];
    self->numVisited = 0;
    self->numWins    = 0;
    self->childrenNodes = nil;
    self->parentKey = nil;
    self->unTriedMoves = [[NSMutableArray alloc] init];
    
    
    //CCSprite* oneSlot = nil;
    for (int col = 0; col < self->boardSize; col++){
        int emptyRow = 0;
        
        while ([_gameStateCopy getSlotFrom:col and:emptyRow].tag != empty
               && emptyRow != self->boardSize){
            emptyRow++;
        }
        
        if (emptyRow != self->boardSize){
            NSString *key = [_gameStateCopy toTupleFrom:col andY:emptyRow];
            [self->unTriedMoves addObject:(NSString*)key];
        }
    }
    
    return self;
}

-(int)getNumWins{
    return self->numWins;
}
-(int)getNumVisited{
    return self->numVisited;
}


-(MCSTNode*) UCTSelectChild{
    
   // s = sorted(self.childNodes, key = lambda c: (float(c.wins)/float(c.visits)) + math.sqrt(2 * math.log(float(self.visits) / float(c.visits))))
    //return s[-1]# a tuple
    
   
    
    MCSTNode *mostUrgent;
    
    
    return mostUrgent;
}


-(void)addChild:(MCSTNode *)child{
    return;
}

-(MCSTNode*)getChild:(MCSTNode*)parent{
    MCSTNode *child = nil;
    return child;
}

-(void)updateSimScore:(int)wins and:(int)visited{
    
    return;
}

-(NSString*) runMCS{
    NSString *chosenKey = nil;
    return  chosenKey;
    MCSTNode *rootNode = self;
    MCSTNode *curNode = nil;
    
//    t_start = time.time()
//    t_now = time.time()
//    t_deadline = t_now + THINK_DURATION;
    int iterations = 0;
    
    while( iterations <= 100){
        curNode = rootNode;
        GameBoard *gameCopy = [gameCopy initWithGame:self->_gameStateCopy];
        
        // Selection
        
        while ([curNode->unTriedMoves count] == 0 && curNode->childrenNodes != nil) {
            curNode = [curNode UCTSelectChild];
            
        }
        
    }
//    while t_now < t_deadline:
//        
//        node = rootnode
//        stateCopy = state.copy()
//        
//# Selection
//# while there is no more untried move and there are childeren with this node.
//# pick the most urgent child, and simulate the move. Other children don't matter in selection
//        while node.untriedMoves == [] and node.childNodes != []: # node is fully expanded and non-terminal
//            node = node.UCTSelectChild() # based on UCB, x + c * sqrt (2ln * Pvisited/ stateVisited)
//            stateCopy.apply_move(node.move)  #
//            
//# Expand
//# if there is a untried move, randomly pick one
//# add the node as a child, and get the child
//            if node.untriedMoves != []: # if we can expand (i.e. state/node is non-terminal)
//                m = random.choice(node.untriedMoves)
//                stateCopy.apply_move(m)
//                node = node.AddChild(m,stateCopy) # add child and descend tree
//                
//# Rollout - this can often be made orders of magnitude quicker using a state.GetRandomMove() function
//                
//# Simulation
//# untill there is no more avaiable move or simulating 5 turns, assume the player picks move randomly as well
//# simulate the game
//                depth = 5
//                while stateCopy.get_moves() != [] and  depth > 0: # while state is non-terminal
//                    depth -=1
//                    stateCopy.apply_move(random.choice(stateCopy.get_moves()))
//                    
//# Backpropagate
//# get the current score
//# update the socre of picked child
//                    
//                    score = stateCopy.get_score()
//                    while node != None: # backpropagate from the expanded node and work back to the root node
//                        result = opponentScore(score, node.playerJustMoved)# evaluate the states
//                        node.Update(result)
//                        node = node.parentNode
//                        
//                        iterations += 1
//                        t_now = time.time()
}

-(void)dealloc{
    [self->_gameBoardCopy release];
    self->_gameBoardCopy = nil;
    [self->childrenNodes release];
    self->childrenNodes = nil;
    [self->parentKey release];
    self->parentKey = nil;
    [self->unTriedMoves release];
    self->unTriedMoves = nil;
    
    [super dealloc];
}

@end
