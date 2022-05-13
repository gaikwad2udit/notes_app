import 'package:flutter/material.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/getwidget.dart';

class ScreenLoader extends StatelessWidget {
  const ScreenLoader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 200, 143, 162),
      body: Center(
        child: const GFLoader(
          type: GFLoaderType.ios,
        ),
      ),
    );
  }
}
