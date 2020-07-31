import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';
import 'package:pangle_flutter_example/common/constant.dart';

class BannerPage extends StatefulWidget {
  @override
  _BannerPageState createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Banner Ad'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8.0),
            height: 100,
            alignment: Alignment.center,
            child: Text(
              'Content',
              style: TextStyle(fontSize: 30),
            ),
          ),
          BannerView(
            iOS: IOSBannerAdConfig(slotId: kBannerId),
            android: AndroidBannerAdConfig(slotId: kBannerId, imgSize: PangleImgSize.banner600_150),
          ),
          Expanded(
            child: Container(
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }
}
