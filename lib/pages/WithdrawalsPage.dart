import 'package:flutter/material.dart';

class WithdrawalsPage extends StatefulWidget {
  const WithdrawalsPage({super.key});

  @override
  _WithdrawalsPageState createState() => _WithdrawalsPageState();
}

class _WithdrawalsPageState extends State<WithdrawalsPage> {
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
          children: [Text('Withdrawals Page')],
        ),
      ),
    );
  }
}
