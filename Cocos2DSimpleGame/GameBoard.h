//
//  GameBoard.h
//  Cocos2DSimpleGame
//
//  Created by JIAYU ZENG on 6/25/15.
//  Copyright 2015 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameState.h"

enum{
    empty = 0,
    opponment = -1,
    player = 1
};

@interface GameBoard : CCNode {
    NSMutableDictionary *_gameBoard;
   
    bool playersTurn;
    int BOARD_SIZE;
    bool gameEnded;
    int _connectN;
}

- (id)init:(CGSize)winSize andN:(int)n;
- (GameBoard*)makeGameCopy:(GameBoard*)game;

- (void) dealloc;

- (NSString*) toTupleFrom:(int)x andY: (int)y;
- (int) getXFromKey:(id)key;
- (int) getYFromKey:(id)key;

- (GameState*) getSlotFrom:(int)x and: (int)y;
- (GameState*) getSlotFromKey:(id)key;

- (NSMutableDictionary* )getGameBoard;

- (int)getBoardSize;
- (bool)isPlayerTurn;


- (NSInteger) getNextSlotTag:(int)x and: (int)y;
-(void)applyAction:(int)targetCol and:(int)targetRow;
-(void)applyAction:(GameState*)targetSlot;

- (bool) checkWin:(int)placedX and:(int)placedY with:(NSInteger)whosTurn;
- (NSMutableArray*)getAvailableSlots;
- (float) evaluateState:(int)placedX andY:(int)placedY of:(NSInteger) whosTurn;

-(void)setGameEnded;

-(bool)isGameEnded;

@end
