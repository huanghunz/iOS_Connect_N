//
//  IntroLayer.h
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 11/13/12.
//  Copyright Razeware LLC 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface IntroLayer : CCLayerColor    
{
    CCLabelTTF *_label;
    CCMenuItem *_connect3;
    CCMenuItem *_connect4;
    CCMenuItem *_connect5;
    CCMenuItem *_quit;
    

}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
