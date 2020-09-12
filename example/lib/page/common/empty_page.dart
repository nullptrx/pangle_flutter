import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('No Examples'),
      ),
      body: Center(
        child: Text('Unimplemented'),
      ),
    );
  }
}
