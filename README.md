## NSFLocalizationSynchronizer

我司自用的 .strings 文件和语言包(仅支持 xlsx 文件)之间的双向同步工具。
### macOS App 
下载点[这里](https://github.com/NSFish/NSFLocalizationSynchronizer/releases/download/1.0/NSFLocalizationSynchronizer.app.zip)。

### Command Line Tool 
推荐通过 Homebrew 安装
```shell
brew tap NSFish/tap
brew install nsflocalizer
```

下载点[这里](https://github.com/NSFish/NSFLocalizationSynchronizer/releases/download/1.0/NSFLocalizerCLI)。

### 已实现功能
- 完整导出工程中的所有文案，生成 "key、简体中文、繁体中文、英文、其他语言...、平台" 这样格式的 excel 语言包，供产品及翻译公司使用
- 将产品返还的语言包转换成工程中的 .strings 文件，写回到工程中
- 扫描工程中未多语言化的文案并生成 log

>通常情况下 key 和简体中文是一致的，但同一句文案受限于 UI 元素的宽高不得不简写时，就需要手动指定一个 key。
>
> 平台指某些专属于 iOS/Android 的文案，比如用于 iOS 的 Spotlight 中的搜索结果文案，或是 3D Touch 的菜单项文案。

### 后续维护者需要知道的工作流程
1. 利用 genstrings 解析 .m 和 .swift 文件，并生成 .strings 文件
2. 利用 ibtool 解析 .xib 和 .storyboard 文件，并生成 .strings 文件
3. 读取 12 的产出，每个文件对应生成一个 lineModel 数组
4. 进一步处理 lineModel，如过滤空白行和注释行、去重等，最终生成用于比对的 compareModel 数组
5. 解析语言包文件，同样生成 compareModel 数组
6. 比对两个数组，更新工程端的 compareModel 数组
7. 将 compareModel 转换回 lineModel 数组
8. 结合 4 中记录下来的空白行和注释行，将 lineModel 转换回 .strings 文件
9. 在 git diff 下确认，只有新增加/修改的文案在对应 .strings 文件中发生了变动，大功告成！

>genstrings 生成的 .strings 文件是 UTF-16 Little endian 编码的，需要转换成 UTF-8 才能被 Xcode 识别。
>
>ibtool 生成的 .string 文件中，key 是 UUID
>```C
>/* Class = "UILabel"; text = "仅在Wi-Fi下上传/下载/离线"; ObjectID = "FHM-6o-Xh7"; */
"FHM-6o-Xh7.text" = "仅在Wi-Fi下上传/下载/离线";
>```
>需要统一替换为简体中文。

### 依赖的工具、库
- genstrings
- ibtool
- [XlsxReaderWriter](https://github.com/NSFish/XlsxReaderWriter)
解析及生成、编辑 xlsx 文件，不完美但能用

## TODO（废弃）
- [ ] 多 target 支持
- [ ] 支持对 NSLocalizedString(key, comment) 的简写扫描
