import 'package:flutter/material.dart';

class Testing extends StatefulWidget {
  const Testing({super.key});

  @override
  State<Testing> createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.amber,
              height: 150,
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(20, (index) {
                    return Text('index ke-$index');
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
