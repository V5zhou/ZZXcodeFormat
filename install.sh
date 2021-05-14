#!/bin/bash

xcode_application_path="/Applications/Xcode.app"
xcode_version=`defaults read ${xcode_application_path}/Contents/Info.plist CFBundleShortVersionString`
echo "xcode版本号为：${xcode_version}"

xcode_file_dir="${xcode_application_path}/Contents/MacOS"
xcode_file_path="${xcode_file_dir}/Xcode"
cached_origin_file_path="${xcode_file_dir}/origin_Xcode_${xcode_version}"
cached_resigned_file_path="${xcode_file_dir}/resigned_Xcode_${xcode_version}"

echo "xcode_application_path:$xcode_application_path \n xcode_file_dir:$xcode_file_dir \n xcode_file_path:$xcode_file_path \n cached_origin_file_path:$cached_origin_file_path \n cached_resigned_file_path:$cached_resigned_file_path"

# ################################ private ################################
# 加载clang-format配置文件
function loadSettingFile() {
	# 添加.clang-format文件
	if [ ! -f ~/.clang-format ]; then
		cp .clang-format ~
	else
		echo 'clang-format配置文件已存在\n'
	fi
}

# 添加xcode的UUID到插件
function addPluginsUUID() {
	# PlistBuddy添加Xcode的UUID
	echo "开始获取xcode的uuid"
	xcode_uuid=`defaults read /Applications/Xcode.app/Contents/Info.plist DVTPlugInCompatibilityUUID`
	echo "获取到xcode的uuid为:${xcode_uuid}\n"

	# 查看工程中是否已写入xcode的uuid，如未，则写入
	search_in_plist=`/usr/libexec/PlistBuddy -c "Print :DVTPlugInCompatibilityUUIDs:" ./ZZXcodeFormat/Info.plist | grep $xcode_uuid`

	if [ ${#search_in_plist} == 0 ];then
		echo "不存在Xcode的uuid：${xcode_uuid}，自动添加"
		/usr/libexec/PlistBuddy -c "Add :DVTPlugInCompatibilityUUIDs: string $xcode_uuid" ./ZZXcodeFormat/Info.plist
		echo "添加完成\n"
	else
		echo "已存在xcode_uuid:${xcode_uuid}\n"
	fi
}

# 编译ZZClang
function buildPlugins() {
	echo "开始编译插件"
	xcodebuild -scheme ZZXcodeFormat -configuration Release -quiet
	echo "编译完成\n"
}

# 对xcode进行自签
function resignXcode() {
    if [ -f $cached_resigned_file_path ]; then
        echo "resigned Xcode缓存存在"
        rm $xcode_file_path
		cp -f $cached_resigned_file_path $xcode_file_path
        chmod +x $xcode_file_path
        echo "取resigned Xcode完成"
	else
		echo "resigned缓存不存在，需resign"

        if [ ! -f $cached_origin_file_path ]; then
            echo "备份原Xcode"
            cp $xcode_file_path $cached_origin_file_path
            chmod -x $cached_origin_file_path
            echo "备份原Xcode完成"
        fi
        
        echo "开始对xcode进行自签，请输入mac密码:"
        sudo codesign -f -s XcodeSigner /Applications/Xcode.app
        echo "自签结束\n"
	fi
}

# ################################ public ################################

# 编译插件，并且自签xcode
function install() {
    # 切换文件夹
    cd `dirname $0`
    pwd

    # 1. 加载.clang-format
    # 2. 检查UUID
    # 3. 编译插件
    # 4. 自签Xcode
	loadSettingFile && addPluginsUUID && buildPlugins && resignXcode
}

# 恢复xcode签名
function restore() {
	if [ -f $cached_origin_file_path ]; then
		echo 'origin Xcode缓存存在，开始恢复'
        if [ ! -f $cached_resigned_file_path ]; then
            mv $xcode_file_path $cached_resigned_file_path
            chmod -x $cached_resigned_file_path
        fi
        rm $xcode_file_path
        cp $cached_origin_file_path $xcode_file_path
        chmod +x $xcode_file_path
        echo '恢复完成'
	else
		echo 'origin Xcode缓存不存在，无法恢复'
	fi
}

func=$1
if [ -n func ]; then
    echo "$0 $1"
    if [ $func == "restore" ];then
        restore
    elif [ $func == "install" ]; then
        install
    fi
fi