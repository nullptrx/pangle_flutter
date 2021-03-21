import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pangle_flutter_example/page/native/custom_splash_page.dart';

import '../../common/ext.dart';
import '../../page/native/splash_page.dart';

class NativePage extends StatefulWidget {
  @override
  _NativePageState createState() => _NativePageState();
}

class _NativePageState extends State<NativePage> {
  final pages = {
    'Custom Splash AD': CustomSplashPage(isRoot: false),
    'Splash AD': SplashPage(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Express Examples'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: pages.length,
          itemBuilder: (context, index) {
            var titles = pages.keys.toList();
            final title = titles[index];
            return ListTile(
              title: Text(title),
              trailing: Icon(Icons.navigate_next),
              onTap: () => _onTapItem(title),
            );
          },
        ),
      ),
    );
  }

  _onTapItem(String title) {
    context.navigateTo(pages[title]);
  }
}
