//
//  GameOverLayer.m
//  Connect4-Clone
//
//  Created by JIAYU ZENG on 7/2/15.
//  Copyright 2015 jz. All rights reserved.
//

#import "GameOverLayer.h"
#import "HelloWorldLayer.h"

@implementation GameOverLayer

// Recieve an integer to select which message to display
+(CCScene *) sceneWithWon:(NSInteger)won {
    CCScene *scene = [CCScene node];
    GameOverLayer *layer = [[[GameOverLayer alloc] initWithWon:won] autorelease];
    [scene addChild: layer];
    return scene;
}


/* ==========  initWithWon =================
 Initializing game over layer
 pre: NSInteger --- information about the winner
 post: display winning condition
 */
- (id)initWithWon:(NSInteger)won {
    if ((self = [super initWithColor:ccc4(255, 255, 255, 255)])) {
        NSString * message = nil;
        if (won == 1){
            message = @"You Won!";
        }
        else if (won == -1){
            message = @"AI Won!";
        }
        else
            message = @"The System Won!";
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCLabelTTF * label = [CCLabelTTF labelWithString:message fontName:@"Arial" fontSize:32];
        label.color = ccc3(0,0,0);
        label.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:label];
        
        _quit = [ CCMenuItemImage itemWithNormalImage:@"quit.png" selectedImage:@"Quit.png" target:self selector:@selector(buttonTapped:)];
        _quit.position = ccp(winSize.width/2,winSize.height/2-50);
        
        
        // display buttons
        CCMenu *starMenu = [CCMenu menuWithItems:  _quit, nil];
        starMenu.position = CGPointZero;
        
        [self addChild:starMenu];

        
       
    }
    return self;
}

/* ========== buttonTapped =================
 Responds when the quit button is pressed.
 pre: the button
 post: quit game
 */
- (void)buttonTapped:(id)sender {
    
    [[CCDirector sharedDirector] end];
    exit(0);
    
}


@end

