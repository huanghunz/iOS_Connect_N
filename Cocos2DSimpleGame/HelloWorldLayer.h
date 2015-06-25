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
//#import "GameBoard.h"

// HelloWorldLayer
//extern int const BOARD_SIZE;
//int const BOARD_SIZE = 8;

@interface HelloWorldLayer : CCLayerColor
{
    NSMutableArray * _monsters;
    NSMutableArray * _projectiles;
    int _monstersDestroyed;
    
    NSMutableDictionary *_gameBoard;
    bool isPlayerTurn;
    
}


- (NSString*) toTupleFrom:(int)x andY: (int)y;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
