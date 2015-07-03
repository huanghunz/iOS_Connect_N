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
    NSMutableDictionary *_gameBoard;
    
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


- (NSInteger) getNextSlotTag:(int)x and: (int)y;

-(void)applyAction:(int)targetCol and:(int)targetRow;
-(void)applyAction:(GameState*)targetSlot;

- (bool) checkWin:(int)placedX and:(int)placedY with:(NSInteger)whosTurn;
- (NSMutableArray*)getAvailableSlots;
- (float) evaluateState:(int)placedX andY:(int)placedY of:(NSInteger) whosTurn;

-(bool)isGameEnded;
- (void) dealloc;

@end
