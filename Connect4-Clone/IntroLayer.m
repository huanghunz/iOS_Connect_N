//
//  IntroLayer.m
//  Connect4-Clone
//
//  Created by JIAYU ZENG on 7/2/15.
//  Copyright jz 2015. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "HelloWorldLayer.h"


#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

/* ==========  init =================
Initializing intro layer
pre: nothing
post: setup the layer of buttons and labels
*/
-(id) init
{
    if ((self = [super initWithColor:ccc4(00,00,00,255)])) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // Create a label for display purposes
        _label = [[CCLabelTTF labelWithString:@"Please choose a mode: \n(connect-N:if you connect your pieces\n horizontally, vertically or diagonally with N pieces, you win." fontName:@"Arial" fontSize:11.0 dimensions:CGSizeMake(winSize.width, 100)  hAlignment:UITextAlignmentCenter] retain];
        
        _label.position = ccp(winSize.width/2,
                              winSize.height-100);
        
        [ _label setColor:ccc3(100,100,0)];
        [self addChild:_label];
        
        // creating buttons.
        
        _connect4 = [ CCMenuItemImage itemWithNormalImage:@"connect4.png" selectedImage:@"connect4-pressed.png" target:self selector:@selector(starButtonTapped:)];
        _connect4.position = ccp(winSize.width/2, 180);
        
        _connect5 = [ CCMenuItemImage itemWithNormalImage:@"connect5.png" selectedImage:@"connect5-pressed.png" target:self selector:@selector(starButtonTapped:)];
        _connect5.position = ccp(winSize.width/2, 160);
        
        _connect6 = [ CCMenuItemImage itemWithNormalImage:@"connect6.png" selectedImage:@"connect6-pressed.png" target:self selector:@selector(starButtonTapped:)];
        _connect6.position = ccp(winSize.width/2, 140);

        
        _quit = [ CCMenuItemImage itemWithNormalImage:@"quit.png" selectedImage:@"Quit.png" target:self selector:@selector(starButtonTapped:)];
        _quit.position = ccp(winSize.width/2, 120);
        
        
        
        // display buttons
        CCMenu *starMenu = [CCMenu menuWithItems: _connect6, _connect4, _connect5, _quit, nil];
        starMenu.position = CGPointZero;
        
        [self addChild:starMenu];
        
    }
    return self;
}

/* ==========  startButtonTapped =================
 Responds when any of the button is pressed.
 pre: the pressed button
 post: go to HelloWorld layer or Quit
 */
- (void)starButtonTapped:(id)sender {
    
    int chosenN = 0;
    CCMenuItem *pressedItem = ( CCMenuItem *)sender;
    
    if (pressedItem == _connect6) {
        chosenN = 6;
    } else if (pressedItem == _connect4) {
        chosenN = 4;
    }
    else if (pressedItem == _connect5){
        chosenN = 5;
    }
    else{
        [[CCDirector sharedDirector] end];
        exit(0);
    }
    
    NSString *message = [NSString stringWithFormat:@"Game Mode: Connect-%d", chosenN];
    [_label setString:  message];
    
    [ message release];
    
    // pass var to game layer
    CCScene *startGameScene = [ HelloWorldLayer scene:chosenN ];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:2.0 scene:startGameScene ]];
    
}

-(void) dealloc{
    [super dealloc];
}
@end
