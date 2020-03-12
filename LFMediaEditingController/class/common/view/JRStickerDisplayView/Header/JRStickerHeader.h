//
//  JRStickerHeader.h
//  StickerBooth
//
//  Created by djr on 2020/3/4.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#ifndef JRStickerHeader_h
#define JRStickerHeader_h

// get方法
#define JRSticker_bind_var_getter(varType, varName, target) \
- (varType)varName \
{ \
    return target.varName; \
}

// set方法
#define JRSticker_bind_var_setter(varType, varName, setterName, target) \
- (void)setterName:(varType)varName \
{ \
    [target setterName:varName]; \
}


#define jr_NotSupperGif

#endif /* JRStickerHeader_h */
