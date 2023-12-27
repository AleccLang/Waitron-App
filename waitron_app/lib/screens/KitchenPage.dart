import 'package:flutter/material.dart';
import 'package:waitron_app/screens/WaitronPage.dart';


class KitchenPage extends StatelessWidget {
  const KitchenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 9.0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Placed'),
              Tab(text: 'In Progress'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrderList(status: 'Placed'),
            OrderList(status: 'In Progress'),
          ],
        ),
      ),
    );
  }
}