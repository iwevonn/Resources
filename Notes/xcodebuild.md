
###使用xcodebuild和xcrun打包签名




######1. 查看targets && Configurations

`xcodebuild -list`: 使用方式，查看 project 中的 targets 和 configurations，或者 workspace 中 schemes, 输出如下:

```
Information about project "YourObject":
    Targets:
        YourObject
        YourObject-Dev
        YourObject-Local
        YourObject-DEV

    Build Configurations:
        Debug
        Release

    If no build configuration is specified and -scheme is not passed then "Release" is used.

    Schemes:
        YourObject
        YourObject-Dev
        YourObject-Local
        YourObject-DEV
```


######2. Build

- 2.1 `xcodebuild [-project name.xcodeproj] [[-target targetname] ... | -alltargets] build`: 
*使用方式，会 build 指定 project，其中 -target 和 -configuration 参数可以使用 xcodebuild -list 获得，-sdk 参数可由 xcodebuild -showsdks 获得，[buildsetting=value ...] 用来覆盖工程中已有的配置。*

- ```
xcodebuild -project YourObject.xcodeproj -target YourObject build


- 2.2 `xcodebuild -workspace name.xcworkspace -scheme scheme name build`: 
*使用方式，build 指定 workspace，当我们使用 CocoaPods 来管理第三方库时，会生成 xcworkspace 文件，这样就会用到这种打包方式*

- ```
xcodebuild -workspace YourObject.xcworkspace -scheme YourObject build


- |		    Parameter       |					                     Note                                            | Required |
| ------------------------- |:-------------------------------------------------------------------------------------:|:-------:|
| -project </br> -workspace	 | 这两个对应的就是项目的名字也就是说哪一个工程要打包。如果有多个工程，这里又没有指定，则默认为第一个工程 |    YES   |
|			-target			 | 打包对应的targets，如果没有指定这默认第一个                                                 |    NO    |
|			-scheme			 | 指定打包的scheme                                                                        |    NO    |


######3. 打包 
*命令行进入我现在的一个项目目录，查看一下项目信息，`xcodebuild -list`*

- 3.1 build项目
- `xcodebuild -workspace YourObject.xcworkspace -scheme YourObject -configuration Release`
- 成功后会显示`app文件`目录

- 3.2在 Release-iphoneos 文件夹下，有我们需要的.app文件，但是要安装到真机上，我们需要将该文件导出为ipa文件，这里使用xcrun命令:
- `xcrun -sdk iphoneos -v PackageApplication /Users/isoftstone/Library/Developer/Xcode/DerivedData/YourObject-fsvqbepqxdkfnzbkmpxfgfctzqum/Build/Products/Release-iphoneos/YourObject.app -o ~/Desktop/YourObject.ipa`
- 成功后会在输出路径中显示ipa包*此ipa文件为内测版*


######4. 对自动化打包进行的各种封装
- 4.1 网络第三方解决办法
	- 4.1.1 比较出名的就是facebook出的 [xctool](https://github.com/facebook/xctool)
	- 4.2 一个python脚本[autobuild.py](https://github.com/carya/Util)

- 4.2 脚本化中使用如下的命令打包:
	- 4.2.1 生成app文件
	
	- ```
xcodebuild -project name.xcodeproj -target targetname -configuration Release -sdk iphoneos build CODE_SIGN_IDENTITY="$(CODE_SIGN_IDENTITY)" PROVISIONING_PROFILE="$(PROVISIONING_PROFILE)"

	- ```
xcodebuild -workspace name.xcworkspace -scheme schemename -configuration Release -sdk iphoneos build CODE_SIGN_IDENTITY="$(CODE_SIGN_IDENTITY)" PROVISIONING_PROFILE="$(PROVISIONING_PROFILE)"

	- 示例: `xcodebuild -workspace YourObject.xcworkspace -scheme YourObject -configuration Release -sdk iphoneos build"`
	```
	Usage: autobuild.py [options]
  Options:
 		 -h, --help            show this help message and exit
 		 -w name.xcworkspace, --workspace=name.xcworkspace
                      		  Build the workspace name.xcworkspace.
		  -p name.xcodeproj, --project=name.xcodeproj
                      		  Build the project name.xcodeproj.
		  -s schemename, --scheme=schemename
                 		       Build the scheme specified by schemename. Required if
                    		    building a workspace.
 		 -t targetname, --target=targetname
                     		   Build the target specified by targetname. Required if
                     		   building a project.
		  -o output_filename, --output=output_filename
                    		    specify output filename
	```
	脚本中有几个全局变量，根据自己项目设置进行修改其值, 包括:
	- ```
	CODE_SIGN_IDENTITY = "iPhone Distribution: xxxxxxxx Co. Ltd (xxxxxxx9A)"
	PROVISIONING_PROFILE = "xxxxxxxxxx-xxxxx-xxxxx-xxxx-xxxxxxxxxxxx"
	CONFIGURATION = "Release"
	SDK = "iphoneos"
	
	- 4.2.2 使用 xcrun 生成 ipa 文件:
	```
	xcrun -sdk iphoneos -v PackageApplication ./build/Release-iphoneos/$(target|scheme).app
  ```
	-  *"./build/Release-iphoneos/$(target|scheme).app"* －－ 指app包全路径

---
######参考
[敲一下enter键，完成iOS的打包工作](http://ios.jobbole.com/84677/)

[iOS自动打包并发布脚本](http://liumh.com/2015/11/25/ios-auto-archive-ipa/#build-and-sign-ipa)

