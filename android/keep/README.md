# 白名单防混淆配置文件生成

因平台SDK包中whiteList.txt 白名单上的资源不支持混淆，该项目将`whiteList.txt`转换为`pangle_flutter_keep.xml`，然后将该文件拷贝至 `res/raw/`目录下即可，本项目已加入该文件，无需再加。



# 构建

```shell
./build.sh
```



# 使用

```shell
# 把whilteList.txt拷贝至convert同级目录下，执行如下命令，即可生成pangle_flutter_keep.xml
./convert 
```



