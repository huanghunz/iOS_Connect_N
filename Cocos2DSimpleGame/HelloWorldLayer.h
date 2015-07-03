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
#import "GameStack.h"

// HelloWorldLayer
//extern int const BOARD_SIZE;
//int const BOARD_SIZE = 8;



@interface HelloWorldLayer : CCLayerColor
{
    GameBoard *_game;
    CCSprite *_undo;
    CCSprite *_quit;
    
    GameStack *_gameStack;
    int numTurns;
    
    int connectNGame;
    int boardSize;
    float boardOriX;
    
    NSMutableArray *_addedPieces;
    NSMutableArray *_arrowCol;
    bool animationStarted;
    bool animationRuning;
       
}

//- (NSString*) toTupleFrom:(int)x andY: (int)y;
//- (int) getYFromKey:(id)key;
//- (int) getXFromKey:(id)key;
//- (NSInteger) getNextSlotTag:(int)x and: (int)y;
//- (bool) checkWin:(int)placedX and:(int)placedY with:(NSInteger)whosTurn;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene:(int)n;

@end
