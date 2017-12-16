//
//  MyMoney.m
//  breadwallet
//
//  Created by Kevin Zhang (BCG DV) on 12/15/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "MyMoney.h"
#import "BRBIP39Mnemonic.h"
#import "BRBIP32Sequence.h"
#import "BRKey.h"

@interface MyMoney()

@property(strong, nonatomic) BRBIP39Mnemonic *mnemonic;
@property (nonatomic, strong) id<BRKeySequence> _Nullable sequence;

@end

@implementation MyMoney

-(id)init {
    self = [super init];
    self.mnemonic = [BRBIP39Mnemonic new];
    self.sequence = [BRBIP32Sequence new];
    return self;
}

-(void)getMoneyBack {
    [self getPermutations:@"地球中国江苏斜桥安宁" str:@"村唐张家" size:2];
    NSLog(@"done");
}

-(void) checkPhrase:(NSString*)seedPhrase {
    NSString* target = @"1LnqbRa3YPBUiKgSSbakG2ruuP1tQtQmWY";
    NSData *masterPubKey = [self.sequence masterPublicKeyFromSeed:[self.mnemonic
                                                                   deriveKeyFromPhrase:seedPhrase withPassphrase:nil]] ;
    for(int n=0; n<2; n++) {
        BRKey *k = [BRKey keyWithPublicKey:[self.sequence publicKey:n internal:NO masterPublicKey:masterPubKey]];
        NSString *addr = k.address;
        if([target isEqualToString:addr]) {
            NSLog(@"%@ : %@", seedPhrase, addr);
            NSLog(@"got it");
        }
    }
}

-(void) doPermute:(NSString*)prefix chars:(NSMutableArray *)input output:(NSMutableArray *)output used:(NSMutableArray *)used size:(int) size level:(int) level {
    if (size == level) {
        NSMutableArray* ma = [NSMutableArray new];
        for(int i=0;i<prefix.length;i++) {
            [ma addObject:[prefix substringWithRange:NSMakeRange(i, 1)]];
        }
        [ma addObjectsFromArray:output];
        NSString *word = [ma componentsJoinedByString:@" "];
        BOOL valid = [self.mnemonic phraseIsValid:word];
        if(valid) {
            [self checkPhrase:word];
            NSLog(@"==== %@ ", word);
        }
        return;
    }
    
    level++;
    
    for (int i = 0; i < input.count; i++) {
        if ([used[i] boolValue]) {
            continue;
        }
        
        used[i] = [NSNumber numberWithBool:YES];
        [output addObject:input[i]];
        [self doPermute:prefix chars:input output:output used:used size:size level:level];
        used[i] = [NSNumber numberWithBool:NO];
        [output removeLastObject];
    }
}

-(void)getPermutations:(NSString *)prefix str:(NSString*)input size:(int) size {
    NSMutableArray *chars = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [input length]; i++) {
        NSString *ichar  = [input substringWithRange:NSMakeRange(i, 1)];
        [chars addObject:ichar];
    }
    
    NSMutableArray *output = [[NSMutableArray alloc] init];
    NSMutableArray *used = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < chars.count; i++) {
        [used addObject:[NSNumber numberWithBool:NO]];
    }
    
    [self doPermute:prefix chars:chars output:output used:used size:size level:0];
}

@end

