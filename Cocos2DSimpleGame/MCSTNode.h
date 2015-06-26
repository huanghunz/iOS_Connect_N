//
//  MCSTNode.h
//  Cocos2DSimpleGame
//
//  Created by JIAYU ZENG on 6/25/15.
//  Copyright 2015 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface MCSTNode : CCNode {
    
    NSMutableArray *_gameBoardCopy;
    int numVisited;
    int numWins;
    NSMutableArray *unTriedMoves;
    NSString* parentKey;
    MCSTNode *childrenNodes;
}

-(id)init:(NSMutableDictionary*)gameBoard;

-(NSString*) UCTSelectChild;


-(void)addChild:(MCSTNode *)child;

-(MCSTNode*)getChild:(MCSTNode*)parent;

-(void)updateSimScore:(int)wins and:(int)visited;

-(NSString*) runMCS;

-(int) getNumWins;
-(int) getNumVisited;


-(void)dealloc;





@end
