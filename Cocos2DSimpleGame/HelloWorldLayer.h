//
//  HelloWorldLayer.h
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 11/13/12.
//  Copyright Razeware LLC 2012. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "GameBoard.h"
#import "MCSTNode.h"

// HelloWorldLayer
//extern int const BOARD_SIZE;
//int const BOARD_SIZE = 8;

@interface HelloWorldLayer : CCLayerColor
{
    
   // NSMutableDictionary *_gameBoard;
    bool isPlayerTurn;
    GameBoard *_game;
    int boardSize;
    
}

- (NSString*) toTupleFrom:(int)x andY: (int)y;
- (int) getYFromKey:(id)key;
- (int) getXFromKey:(id)key;
- (NSInteger) getNextSlotTag:(int)x and: (int)y;
- (bool) checkWin:(int)placedX and:(int)placedY with:(NSInteger)whosTurn;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
