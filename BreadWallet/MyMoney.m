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
    NSMutableArray* candidates = [self getCandidates];
    [candidates addObject:@"inner kiwi chapter crunch math rookie spirit unknown pizza imitate table humor"];
    [candidates addObject:@"quit easy senior orient awake congress runway shrimp loop quarter slogan enter"];
    for (NSString* seedPhrase in candidates) {
        [self checkPhrase:seedPhrase];
    }
    NSLog(@"done");
}

-(void) checkPhrase:(NSString*)seedPhrase {
    NSString* target = @"1LnqbRa3YPBUiKgSSbakG2ruuP1tQtQmWY";
    NSData *masterPubKey = [self.sequence masterPublicKeyFromSeed:[self.mnemonic
                                                                   deriveKeyFromPhrase:seedPhrase withPassphrase:nil]] ;
    for(int n=0; n<10; n++) {
        BRKey *k = [BRKey keyWithPublicKey:[self.sequence publicKey:n internal:NO masterPublicKey:masterPubKey]];
        NSString *addr = k.address;
        NSLog(@"%@ : %@", seedPhrase, addr);
        if([target isEqualToString:addr]) {
            NSLog(@"got it");
        }
    }
}

-(NSMutableArray*) getCandidates {
    NSMutableArray* candidates = [NSMutableArray new];
    NSMutableArray* array = getPermutations(@"安宁唐张家", 4);
    for (NSString* str in array) {
        NSString *word0  = [str substringWithRange:NSMakeRange(0, 1)];
        NSString *word1  = [str substringWithRange:NSMakeRange(1, 1)];
        NSString *word2  = [str substringWithRange:NSMakeRange(2, 1)];
        NSString *word3  = [str substringWithRange:NSMakeRange(3, 1)];
        NSString* phrase = [NSString stringWithFormat:@"地 球 中 国 江 苏 斜 桥 %@ %@ %@ %@", word0, word1, word2, word3];
        BOOL valid = [self.mnemonic phraseIsValid:phrase];
        if(valid) {
            [candidates addObject:phrase];
            NSLog(@"==== %@ ", phrase);
        }
    }
    return candidates;
}

-(NSMutableArray*)expand:(NSString*)str {
    return nil;
}


void doPermute(NSMutableArray *results, NSMutableArray *input, NSMutableArray *output, NSMutableArray *used, int size, int level) {
    if (size == level) {
        NSString *word = [output componentsJoinedByString:@""];
        [results addObject:word];
        return;
    }
    
    level++;
    
    for (int i = 0; i < input.count; i++) {
        if ([used[i] boolValue]) {
            continue;
        }
        
        used[i] = [NSNumber numberWithBool:YES];
        [output addObject:input[i]];
        doPermute(results, input, output, used, size, level);
        used[i] = [NSNumber numberWithBool:NO];
        [output removeLastObject];
    }
}

NSMutableArray *getPermutations(NSString *input, int size) {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
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
    
    doPermute(results, chars, output, used, size, 0);
    
    return results;
}

@end

