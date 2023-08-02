import 'package:flutter/material.dart';

class ContributionsPage extends StatefulWidget {
  const ContributionsPage({super.key});

  @override
  _ContributionsPageState createState() => _ContributionsPageState();
}

class _ContributionsPageState extends State<ContributionsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Contributions Page')],
        ),
      ),
    );
  }
}
