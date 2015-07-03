//
//  HelloWorldLayer.h
//  Connect4-Clone
//
//  Created by JIAYU ZENG on 7/2/15.
//  Copyright jz 2015. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "MCTSNode.h"
#import "GameStack.h"
#import "GameOverLayer.h"


// HelloWorldLayer

@interface HelloWorldLayer : CCLayerColor
{
    Game *_game;
    
    GameStack *_gameStack;
    int numTurns;
    
    int boardSize;
    float boardOriX;
    
    NSMutableArray *_arrowCol;
    CCSprite *_undo;
    CCSprite *_quit;
    
    bool animationStarted;
    bool animationRuning;
    
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene:(int)n;

@end
