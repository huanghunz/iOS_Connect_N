//
//  GameOverLayer.h
//  Connect4-Clone
//
//  Created by JIAYU ZENG on 7/2/15.
//  Copyright 2015 jz. All rights reserved.
//

#import "cocos2d.h"

@interface GameOverLayer : CCLayerColor{
    CCMenuItem *_quit;
}

+(CCScene *) sceneWithWon:(NSInteger)won;
- (id)initWithWon:(NSInteger)won;

@end
