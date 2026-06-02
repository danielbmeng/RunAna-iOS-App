# RunAna

RunAna is a SwiftUI iOS app that uses OpenAI Vision to analyze photos and generate polished social captions in English or Chinese. It supports multiple caption tones, visual themes, local caption history, credit-style usage limits, and secure on-device API key storage through Keychain.

RunAna 是一款 SwiftUI iOS 应用，可使用 OpenAI Vision 分析照片，并生成适合社交平台发布的中英文文案。应用支持多种文案语气、视觉主题、本地历史记录、credit 式使用限制，以及通过 Keychain 在设备端安全保存 API key。

## Features

- Pick up to 3 photos from the photo library
- Generate one short caption and one longer reflective caption
- Choose up to 3 tones, including fresh, literary, philosophical, cinematic, gentle, and more
- Switch between English and Simplified Chinese output
- Customize the app theme
- Save recent caption drafts locally
- Store the OpenAI API key securely in Keychain
- Track local credit usage for prototype testing

## 功能

- 从相册选择最多 3 张照片
- 生成一条短文案和一条更完整的长文案
- 可选择最多 3 种语气，包括小清新、文艺范、哲学范、电影感、温柔松弛等
- 支持英文和简体中文输出
- 支持切换应用主题
- 本地保存最近生成的文案草稿
- 使用 Keychain 在设备端安全保存 OpenAI API key
- 提供本地 credit 使用限制，方便原型测试

## OpenAI key

For local testing, add the key inside the app settings screen. Do not hard-code OpenAI API keys into the iOS client. A production app should call your own backend, and the backend should store the OpenAI key in an environment variable.

The key previously pasted into chat should be revoked and regenerated.

## OpenAI API key

本地测试时，请在 app 的 Settings 页面输入 OpenAI API key。不要把 OpenAI API key 硬编码到 iOS 客户端中。正式发布时，建议改为调用你自己的后端服务，并由后端通过环境变量保存和使用 OpenAI key。

如果某个 key 曾经被粘贴到聊天、代码或公开位置，请在 OpenAI 后台撤销并重新生成。

## Open

```sh
open RunAna.xcodeproj
```

The current machine may need full Xcode selected before `xcodebuild` can compile iOS apps.

## 打开项目

```sh
open RunAna.xcodeproj
```

如果本机 `xcodebuild` 指向 Command Line Tools，可能需要先切换到完整 Xcode 后才能编译 iOS app。
