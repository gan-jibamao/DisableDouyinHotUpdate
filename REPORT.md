# 禁用抖音热更新 — 提取报告

来源：com.xuuz.douyinhelper_2.2-6_iphoneos-arm64.deb → DouyinHelper.dylib（18MB，chained fixups，无符号表）

## 原版机制（逆向定位）

DouyinHelper 在 Hook 注册大函数内（0x401A8-0x401F0，无条件注册，无设置开关）：

```
401a8:  bl 0xa3e990                      ; objc_getClass("AWEDynamicPatchModel")   [字符串 0xCA3D47]
401b4:  mov x19, x0                      ; cls
401bc:  ldr x1, [selref]                 ; @selector(setRawData:)                  [0x100C2B8]
401c0:  adr x2, 0x42c48                  ; 新 IMP
401cc:  bl 0xa3df28                      ; MSHookMessageEx(cls, sel, newIMP, &orig=0x101B888)

401d8:  ldr x1, [selref]                 ; @selector(setSourceRawData:)            [0x100C4C0]
401dc:  adr x2, 0x42cb4                  ; 新 IMP
401f0:  bl 0xa3df28                      ; MSHookMessageEx(cls, sel, newIMP, &orig=0x101B890)
```

## AWEDynamicPatchModel 是什么

抖音 AWE 框架的**动态补丁（热更新）数据模型**。服务端下发的热更新补丁
（字节码/配置）通过 `setRawData:` / `setSourceRawData:` 写入模型后生效。
Hook 两个 setter 把补丁数据置空 → 热更新补丁静默失效（不崩溃、不报错）。

两个替换实现（0x42C48 / 0x42CB4）逻辑一致：
1. 经共享处理函数 0x44820（日志/透传）处理传入数据
2. 调原实现（保留类结构，避免崩溃）——数据已被处理，补丁不落地

## 提取产物

| 文件 | 说明 |
|---|---|
| Tweak.x | Logos 源码（等价实现，%orig(nil) 置空） |
| Makefile | Theos 构建文件 |
| control | deb 控制文件（com.xuuz.disablehotupdate） |
| DisableDouyinHotUpdate.plist | 过滤器：国服/Lite/国际服 |
| build.sh | 一键构建脚本（需 Theos） |

## 关键地址速查（原 dylib）

| 项 | 地址 |
|---|---|
| AWEDynamicPatchModel 字符串 | 0xCA3D47 |
| hook 注册点 | 0x401A8 - 0x401F0 |
| 替换实现 setRawData: | 0x42C48 |
| 替换实现 setSourceRawData: | 0x42CB4 |
| 共享处理函数 | 0x44820 |
| MSHookMessageEx stub | 0xA3DF28 |
| orig IMP 槽 | 0x101B888 / 0x101B890 |
