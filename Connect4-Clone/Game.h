//
//  Game.h
//  Connect4-Clone
//
//  Created by JIAYU ZENG on 7/2/15.
//  Copyright 2015 jz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameState.h"

enum{ // State tags
    empty = 0,
    opponment = -1,
    player = 1
};

@interface Game : NSObject {
    NSMutableDictionary *_gameBoard; // each dict has a GameState Class, which has boundingBox location and state: empty, belongs to human player or belongs to AI player
    
    bool _playersTurn;
    int BOARD_SIZE;
    int _connectN;
    bool gameEnded;
}

- (id)init:(CGSize)winSize andN:(int)n;
- (Game*)makeGameCopy:(Game*)game;

- (NSString*) toTupleFrom:(int)x andY: (int)y;

-(void) getX:(int*)x andY:(int*)y fromKey:(NSString*)key;
- (GameState*) getSlotFrom:(int)x and: (int)y;
- (GameState*) getSlotFromKey:(id)key;

- (NSMutableDictionary* )getGameBoard;

- (int)getBoardSize;
- (bool)isPlayerTurn;


- (NSInteger) getLowerSlotState:(int)x and: (int)y;

-(void)applyAction:(int)targetCol and:(int)targetRow;
-(void)applyAction:(GameState*)targetSlot;

- (bool) checkWin:(int)placedX and:(int)placedY with:(NSInteger)whosTurn;
- (NSMutableArray*)getAvailableSlots;
- (float) evaluateState:(int)placedX andY:(int)placedY of:(NSInteger) whosTurn;


- (void) dealloc;

@end
