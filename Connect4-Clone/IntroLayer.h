//
//  IntroLayer.h
//  Connect4-Clone
//
//  Created by JIAYU ZENG on 7/2/15.
//  Copyright jz 2015. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

@interface IntroLayer : CCLayerColor
{
    CCLabelTTF *_label;
    CCMenuItem *_connect4;
    CCMenuItem *_connect5;
    CCMenuItem *_connect6;

    CCMenuItem *_quit;
    
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
