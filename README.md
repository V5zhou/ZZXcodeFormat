# ZZXcodeFormat

## 更新后特色
支持OC与swift代码格式化，支持xcode9，10。

## 安装方法
1. 创建自签名证书：
    ```
    钥匙串访问
    打开菜单：钥匙串访问－》证书助理－》创建证书…
    输入证书名称：XcodeSigner；
    选择身份类型：自签名根证书 （Identity Type to Self Signed Root）
    选择证书类型：代码签名 （Certificate Type to Code Signing）
    一路继续，生成证书XcodeSigner，生成后可以在钥匙串中看到。
    ```
2. 下载ZZXcodeFormat，直接运行one_key_install，so easy。

## one_key_install为您做了什么？

1. 添加`.clang-format`配置文件到个人文件夹`~`，clang-format脚本的规则配置在这里，当然您可以个性化配置，参考[这里](http://clang.llvm.org/docs/ClangFormatStyleOptions.html)
2. 检查并添加Xcode的UUID
3. 编译插件
4. 执行xcode自签名(期间需要输入密码，自签大约会消耗10分钟)

执行过后，重启Xcode，如果弹框就选LoadBundle，您就可以在Xcode->Edit栏中看到ZZXcodeFormat了。插件目录：
> open -R ~'/Library/Application Support/Developer/Shared/Xcode/Plug-ins/ZZXcodeFormat.xcplugin'

## 功能介绍

ZZXcodeFormat包含下面功能：

1. 格式化当前Focus窗口：FocusFile
2. 格式化多个选中文件：SelectFiles
3. 格式化当前选中文本区域：SelectText

## 额外配置
目前我已经为上面三项添加了快捷键i/o/p，辅助键为control+option+command。当然您可以自定义配置快捷键。
例如，为FocusFile添加快捷键：

> 系统设置->键盘->快捷键->应用快捷键->点击添加->应用程序选择Xcode，菜单标题输入FocusFile，键盘快捷键设置shift+command+L.

打开Xcode，点开ZZXcodeForamt，就会发现显示在我们添加的菜单中了。

## 附一张format FocusFile效果
![Focus](https://github.com/V5zhou/ZZClang-format/blob/master/ZZClang-format/FocusFile%E6%A0%BC%E5%BC%8F%E5%8C%96.gif)
