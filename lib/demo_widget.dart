/**
 *
 * Eddie, enguagns2@gmail.com
 *
 */

import 'package:flutter/material.dart';

/// Created On 2019/12/18
/// Description:
///
class DemoWidget extends StatelessWidget {
  final String assets;

  DemoWidget({
    Key key,
    this.assets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: AspectRatio(
        aspectRatio: 0.75,
        child: Container(
          child: Image.asset(assets, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
