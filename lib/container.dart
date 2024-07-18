import 'package:flutter/material.dart';

class MyContainer extends StatelessWidget {
  const MyContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 500,
      margin: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.green,
      ),
    );
  }
}
