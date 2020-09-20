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



