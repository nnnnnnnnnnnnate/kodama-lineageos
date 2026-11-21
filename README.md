# Kodama LineageOS 23.2 (Android 16)

给 **Google Kodama sku16**（与 Lenovo IdeaPad Duet 同款，MediaTek MT8183 平台）做的 **LineageOS 23.2 / Android 16** 移植，带一个可用的「Install to eMMC」安装器：写盘 → Ctrl+U 启动 → 一键装进内部 eMMC。

---

## 参考价值与致谢

这个移植**不是从零开始**，它建立在两个关键项目之上。这两个项目对本仓库有根本性的参考价值和意义：

### 1. `alpha-liu-01/android_device_google_kukui` —— 直接的技术基座

[alpha-liu-01/android_device_google_kukui](https://github.com/alpha-liu-01/android_device_google_kukui)

这是 Kodama / Krane 的 LineageOS 设备树，是本移植**最直接的技术基础**：

- 提供了 Kodama / Krane 完整的**设备树**（board 适配、HAL、sepolicy、keylayout、传感器/音频/触摸等）。
- 提供了 **Linux 6.18.28-mt81 内核 / FIT 构建**与 DTB 编译路径（`bringup/boards/build-dtb.sh`）。
- 定义了 ChromeOS depthcharge 的 **USB（Ctrl+U）启动**流程与「Install to eMMC」安装器模型。
- 给出了 pmOS 风格的分区布局（`pmOS_kernel` / `pmOS_boot` / `super` / `metadata` / `misc` / `userdata`）。

**没有它，就不会有这个移植。** 本仓库的绝大多数代码都来自它的演进；本仓库的工作是在它的基础上修 bug、补适配、并把它做成可发布、可交付的成品。

### 2. `velvet-os/imagebuilder`（Debian 13）—— 最早的硬件验证与分区参考

[velvet-os/imagebuilder](https://github.com/velvet-os/imagebuilder)

它提供了一套**已证实可用、功能完善的 Debian 13 系统包**（本仓库开发时即 `imagebuilder-251115-01`，包含 `.img` 与源码）。它的价值在于：

- **最早证明这台设备（显示、触摸、键盘、USB）可以被一个现代系统完整驱动**，为后续 LineageOS 移植建立了信心和基线。
- 它的 `.img` 和源码提供了早期 **boot / 分区 / 固件** 的参考实现，是理解这台 MT8183 设备硬件链路（面板、触摸、EC、Wi-Fi）的起点。
- 本移植的 USB 启动盘思路与分区布局都受其直接影响。

可以说：**Debian 13 证明了这台机器「能用」，alpha-liu 的设备树证明了它「能跑 LineageOS」，本仓库做了最后的适配与交付。**

### 3. 本仓库完成的工作

- **修复「Install to eMMC」安装器**：去掉 fstab 的 `voldmanaged=usb:auto`，解决 vold 抢占 `pmOS_boot` 导致的 `Same superblock, different security settings` 挂载失败。
- 键盘功能键映射（Whiskers 18d1:503d）、EC Type-C 模块、无线调试跨重启持久化、按系统语言选 NTP 并强制早期对时。
- 重新构建与镜像内核配置 **ABI 匹配的 vendor_dlkm 模块**（修复 Wi-Fi / 蓝牙 / 电池计量 / 自动旋转失效）。
- 产出可直接交付的发布包与安装说明。

---

## 支持设备

| 机型 | 状态 |
| --- | --- |
| Google Kodama **sku16** | ✅ 已实测 |
| 其他 Kodama SKU | ⚠️ 未测试（屏幕/触摸可能不同） |

## 下载

从 GitHub Release 下载 **`lineage-23.2-kukui-20261121.zip`**（约 1.1 GB，zip 内含完整刷机镜像和全部文件）。

校验值：

```
zip  SHA-256: 0c84813160043815549a32753aee26ddcdcef4f2390628c34a2c145a57936fab
img  SHA-256: d839a00c1888a4e05c928a6a4390abaa21c6538097fa7d29a1d46f567010d884
```

（img 在 zip 内，11.8 GB；解压后可 `sha256sum -c kodama-release/SHA256SUMS.txt` 校验全部文件。）

## 刷机方法

1. 准备一张 **≥16 GB** 的 U 盘 / SD 卡（写入会清空整张盘，请先备份）。
2. 用 **Rufus（选 DD 模式）** 或 **BalenaEtcher** 直接写 zip，无需解压。
3. 平板进**开发者模式**：关机后同时按住**电源 + 音量加 + 音量减**约 10 秒，进入恢复界面按 **Ctrl+D**（首次开启会清除本机数据）。
4. 插卡开机，在开发者屏幕按 **Ctrl+U** 从卡启动 Android。
5. 完成首次设置向导后，打开 **Install to eMMC** 应用，选 **Android only**（仅 Android），等待安装完成（不会自动重启）。
6. 拔掉卡，重新开机，即从内部 eMMC 进入系统。

> **不要**把 U 盘镜像直接 `dd` 到 eMMC（两者分区表不同）。「Android only」会清空 eMMC 原有数据。

## 已支持功能（实机验证）

| 功能 | 状态 |
| --- | --- |
| 显示（`auo,b101uan08.3`） | ✅ |
| 触摸 + 手写笔 | ✅ |
| Wi-Fi（QCA6174） | ✅ |
| 蓝牙 | ✅ |
| 电池 / 充电 / 电量计 | ✅ |
| 自动旋转（加速度计/陀螺仪） | ✅ |
| 扬声器 + 麦克风 | ✅ |
| 键盘保护套 + 触控板 | ✅ |
| 亮度调节 | ✅ |
| U 盘启动（Ctrl+U） | ✅ |
| eMMC 安装（Install to eMMC） | ✅ |
| 无线调试（跨重启自恢复） | ✅ |
| U 盘 / USB 大容量存储（C 口） | ✅（需手动挂载） |

## 已知限制

| 问题 | 说明 |
| --- | --- |
| 相机 | ❌ 设备树无摄像头节点，系统报告 0 个相机设备 |
| **3.5 mm 耳机孔** | ❌ 暂不支持 |
| USB-C 只能作主机（host） | ❌ 不能有线 adb / MTP，调试和传文件请用无线 adb |
| 无 RTC | 每次开机时间先回到构建时间，联网后自动校准（中文系统自动用国内 NTP） |
| SELinux | permissive 模式 |
| 外接显示 | 未实现 |

## 无线调试 / 传文件

- **adb over Wi-Fi**：设置 → 开发者选项 → 无线调试，然后 PC 上 `adb connect <平板IP>:5555`（或 `adb pair` 配对）。
- 传文件可用 SFTP（Termux sshd，端口 8022）、FTP（端口 2121）或 `adb push/pull`。

## 构建

设备树在 `device/google/kukui`（分支 `kodama-sku16`）。核心步骤：

```sh
patches/apply-patches.sh /path/to/lineage-23.2
source build/envsetup.sh
lunch lineage_kukui-trunk_staging-userdebug
m superimage
```

构建与安装的详细说明见 `docs/build.md`、`docs/install.md`、`docs/kodama.md`。

## License

设备树为 Apache 2.0（见 `LICENSE`）。内核模块与补丁为 GPL-2.0-only；固件/相机预编译件保留 `NOTICE` 中声明的许可证。
