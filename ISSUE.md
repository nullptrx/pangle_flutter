# 常见问题解决方案

## 1. Pod install 失败

```shell
### Error

​```
NoMethodError - undefined method `size' for nil:NilClass
/Users/su/.rvm/rubies/ruby-2.4.1/lib/ruby/gems/2.4.0/gems/ruby-macho-1.4.0/lib/macho/macho_file.rb:455:in `populate_mach_header'
/Users/su/.rvm/rubies/ruby-2.4.1/lib/ruby/gems/2.4.0/gems/ruby-macho-1.4.0/lib/macho/macho_file.rb:233:in `populate_fields'
/Users/su/.rvm/rubies/ruby-2.4.1/lib/ruby/gems/2.4.0/gems/ruby-macho-1.4.0/lib/macho/macho_file.rb:55:in `initialize_from_bin'
/Users/su/.rvm/rubies/ruby-2.4.1/lib/ruby/gems/2.4.0/gems/ruby-macho-1.4.0/lib/macho/macho_file.rb:33:in `new_from_bin'
/Users/su/.rvm/rubies/ruby-2.4.1/lib/ruby/gems/2.4.0/gems/ruby-macho-1.4.0/lib/macho/fat_file.rb:365:in `block in populate_machos'
...
...
...
――― TEMPLATE END ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

[!] Oh no, an error occurred.
...
...
```

关键：NoMethodError - undefined method `size' for nil:NilClass

解决方案来源：[https://github.com/CocoaPods/CocoaPods/issues/8377](https://github.com/CocoaPods/CocoaPods/issues/8377#issuecomment-554915212)

```shell
flutter clean
rm -Rf ios/Pods
rm -Rf ios/.symlinks
rm -Rf ios/Flutter/Flutter.framework
rm -Rf ios/Flutter/Flutter.podspec
```

## 2. build报错
Command PhaseScriptExecution failed with a nonzero exit code

`/bin/sh "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh"`

如果是flutter构建脚本报错，大概率是Xcode项目与flutter版本不兼容。

解决方案：项目根目录下执行如下命令，重新构建即可

```shell
rm -rf ios/Runner.xcodeproj
flutter create .
```

Solution: Your Xcode project is incompatible with this version of Flutter. Run `rm -rf ios/Runner.xcodeproj` and `flutter create .` to regenerate.



## 3. scanning files to index

一直卡在扫描文件。

解决方案：关闭IDE，然后android项目根目录下执行下面命令行，等待构建成功后重新打开项目。

```shell
./gradlew build
```



