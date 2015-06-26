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
    NSString* parentKey;
    MCSTNode *childrenNodes;
}

-(id)init:(NSMutableArray*)gameBoard;
-(NSString*) UCTSelectChild;
-(void)getAdjacent:(MCSTNode**) children;
-(void)addChild:(MCSTNode *)child;
-(MCSTNode*)getChild:(MCSTNode*)parent;
-(void)updateSimScore:(int)wins and:(int)visited;
-(NSString*) runMCS;



@end
