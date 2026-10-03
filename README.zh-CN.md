# S++ Soldier Progression for Zeta

这是一个用于 **Metal Gear Solid V: The Phantom Pain** 的 Zeta 模块，用来调整野外士兵 A / A+ / A++ / S / S+ / S++ 的生成进度。

它不再像传统 `.mgsv` 版本那样整份覆盖 `MbmCommonSetting.lua`，而是通过 Zeta 的 `MbmCommonSetting` 合并机制修改 `staffBaseRankRanges`，因此更适合与 Infinite Heaven / Zeta 以及其他 Mother Base MOD 共存。

## 当前版本

**v0.9.0-beta**

目前已经确认：

- Zeta 能正确识别并加载模块。
- 菜单可正常显示。
- 模式和设置可以保存/切换。
- S++ 等级表修改能够进入 Zeta 的 Mother Base 配置合并流程。

完整的长期进度曲线仍建议继续实机测试，因此暂定 Beta。

## 需求

- Metal Gear Solid V: The Phantom Pain
- Infinite Heaven
- IHHook
- Zeta (IH Add-on)

## 安装

将压缩包解压到游戏根目录，最终应存在：

`MGS_TPP/mod/zeta/SppSoldierProgression.lua`

如果之前装过测试版，请删除：

`MGS_TPP/mod/zeta/Spp100Zeta.lua`

然后完全退出并重新启动游戏。

进入：

`F3 -> Zeta Menu -> Mod Management -> Gameplay -> S++ Soldier Progression`

将：

`Active = On`

再选择模式并执行：

`Apply / Reload`

之后回到 ACC 或重新进入任务/自由探索，让敌人重新生成。

## 模式

- **Gradual**：前期保持接近原版的低等级进度，后期逐步进入 S / S+ / S++。
- **Gradual+**：类似 Gradual，但 S 从前期就有低概率出现，并随 Mother Base 等级增加。
- **High-A Gradual**：前期从 A / A+ / A++ 开始，后续进入 S / S+ / S++。
- **High-A Gradual+**：High-A 开局，同时 S 从前期就有低概率出现。
- **Custom High Ranks**：自己设置 A / A+ / A++ / S / S+ / S++ 权重。
- **100% S++**：所有基础等级生成概率设为 S++。
- **Vanilla**：不修改士兵等级表。

## Fast MB Brig

可选功能，用于缩短 Mother Base 禁闭室转化等待。它只处理 MB 相关的时间倍率，不是士兵等级生成的一部分。

## 注意

- 当前地图中已经生成的士兵不一定会立刻变化，需要回 ACC 或重进任务刷新。
- INT-SCOPE 没完全升级前，S 级及以上士兵可能显示为 `?` / `??`。
- 不建议同时安装 `spp_gradual.mgsv`、`spp_gradual+.mgsv`、`spp_100%.mgsv` 等旧式 `MbmCommonSetting.lua` 覆盖版本。
- 如果另一个 Zeta 模块也修改 `staffBaseRankRanges`，可通过 Zeta Load Order 决定后应用哪一个。
- 建议保持 Zeta 的 FOB 功能关闭，遵循 Zeta 官方关于在线/FOB 的说明。

## 说明与致谢

本项目是独立的 Zeta 重新实现，不是旧 `S plus plus Soldiers Mod` 的官方更新，也不包含旧 `.mgsv` 文件或游戏资产。

参考：

- Zeta (IH Add-on) — ZIP / ZipfsLaw
- Infinite Heaven — tin man tex
- IHHook — tin man tex 及贡献者
- S plus plus Soldiers Mod — Weq23rfqew；其页面同时注明 Jarhad 与 Rawrkanos 为早期版本作者

Gradual+ 和 High-A 等完整逐阈值数据并未全部公开，因此本项目对应模式属于根据公开行为重新设计的曲线，不宣称与原 `.mgsv` 逐行完全一致。

## AI 使用说明

本项目最初的 Lua 实现与文档使用了大量生成式 AI 辅助，并经过实机配置与测试。发布 Nexus 时应按照 Nexus 当前规则添加 **AI-Generated Content** 标签。
