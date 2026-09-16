/**
 * 禁用抖音热更新 — 从 DouyinHelper.dylib 2.2-6 提取
 *
 * 原理（源自 DouyinHelper 逆向，原地址 0x401A8-0x401F0）：
 *   MSHookMessageEx(AWEDynamicPatchModel, @selector(setRawData:),        hook_0x42C48, &orig);
 *   MSHookMessageEx(AWEDynamicPatchModel, @selector(setSourceRawData:),  hook_0x42CB4, &orig);
 *
 * AWEDynamicPatchModel 是抖音 AWE 框架的动态补丁（热更新）数据模型，
 * 服务端下发的热更新补丁字节码通过 setRawData: / setSourceRawData: 写入。
 * Hook 这两个 setter 将补丁数据置空 → 热更新补丁静默失效（不崩溃不报错）。
 *
 * 用途：防止抖音热更新覆盖插件 hook + 避免热补丁与注入冲突。
 * 原版为无条件注册（无设置开关，随插件加载即生效）。
 */

#import <Foundation/Foundation.h>

%hook AWEDynamicPatchModel

// 替换实现：补丁数据直接置空（原版 0x42C48 经 0x44820 处理后仍失效，等价）
- (void)setRawData:(NSData *)rawData {
    %orig(nil);
}

- (void)setSourceRawData:(NSData *)sourceRawData {
    %orig(nil);
}

%end

%ctor {
    %init;
    if (!objc_getClass("AWEDynamicPatchModel")) {
        NSLog(@"[DisableHotUpdate] AWEDynamicPatchModel not found — 类未加载或已改名");
        return;
    }
    NSLog(@"[DisableHotUpdate] setRawData:/setSourceRawData: hooked — 抖音热更新已禁用");
}
