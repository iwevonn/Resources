
1.打开Terminal，先设置一个环境变量(这个仅仅只是为了输入方便，不是必须的)，命令如下：

```
export THEOS=/opt/theos
```

2.从网上下载最新的TheOS版本：

```
sudo git clone https://github.com/theos/theos.git $THEOS
```

3.安装ldid(这是一个模拟签名的工具，需要单独下载)，命令如下(因权限问题，本人对iphonedevwiki上的命令做了一些修改以达到目的)：

```
sudo curl -s http://dl.dropbox.com/u/3157793/ldid > /tmp/ldid
sudo cp /tmp/ldid $THEOS/bin/
sudo chmod +x $THEOS/bin/ldid
rm /tmp/ldid
```
参考如下的地址:
https://github.com/theos/theos
https://github.com/rpetrich/theos

4.进入你打算放置项目的文件夹

```
cd ~/myObject
```

5.创建工程

```
$THEOS/bin/nic.pl
```

6.此时会看到命令行中的文本提示如下：

```
新版本:
NIC 2.0 - New Instance Creator
------------------------------
  [1.] iphone/activator_event
  [2.] iphone/application_modern
  [3.] iphone/cydget
  [4.] iphone/flipswitch_switch
  [5.] iphone/framework
  [6.] iphone/ios7_notification_center_widget
  [7.] iphone/library
  [8.] iphone/notification_center_widget
  [9.] iphone/preference_bundle_modern
  [10.] iphone/tool
  [11.] iphone/tweak
  [12.] iphone/xpc_service
  
旧版本:  
NIC 1.0 - New Instance Creator
------------------------------
  [1.] iphone/application	(创建普通应用程序)
  [2.] iphone/library		(创建库文件)
  [3.] iphone/preference_bundle		(创建设置束)
  [4.] iphone/tool			(开发那种没有界面的)
  [5.] iphone/tweak			(外挂程序)
```

7.class-dump下载 

```
http://stevenygard.com/download/class-dump-3.5.dmg 


另: 安装class-dump-z (用法 百度)
wget http://networkpx.googlecode.com/files/class-dump-z_0.2a.tar.gz 

```

8.导出 Object.app 的.h文件

```
path路径/class-dump/class-dump -H Object.app -o ObjectFile

另: 如果把‘class-dump’ 放入到'/use/bin'文件内就可用 
class-dump -H Object.app -o ObjectFile

```
