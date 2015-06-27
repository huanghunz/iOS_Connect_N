//
//  GameBoard.h
//  Cocos2DSimpleGame
//
//  Created by JIAYU ZENG on 6/25/15.
//  Copyright 2015 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


enum{
    empty = 0,
    opponment = -1,
    player = 1
};

@interface GameBoard : CCNode {
    NSMutableDictionary *_gameBoard;
    bool isPlayerTurn;
    int BOARD_SIZE;
}

- (id)init:(CGSize)winSize;
- (id)initWithGame:(GameBoard*)game;

- (void) dealloc;

- (NSString*) toTupleFrom:(int)x andY: (int)y;
- (int) getXFromKey:(id)key;
- (int) getYFromKey:(id)key;

- (CCSprite*) getSlotFrom:(int)x and: (int)y;
- (CCSprite*) getSlotFromKey:(id)key;

- (NSMutableDictionary* )getGameBoard;
- (int)getBoardSize;


- (NSInteger) getNextSlotTag:(int)x and: (int)y;


- (bool) checkWin:(int)placedX and:(int)placedY with:(NSInteger)whosTurn;
//- (void)applyMove;

@end
