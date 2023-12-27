import 'package:flutter/material.dart';
import 'package:waitron_app/screens/WaitronPage.dart';


class KitchenPage extends StatelessWidget {
  const KitchenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255,97,166,171),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 246, 246, 233),
          toolbarHeight: 9.0,
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text(
                  'Placed',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Tab(
                child: Text(
                  'In Progress',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
            indicatorColor: Color.fromARGB(255, 97, 166, 171),
            labelColor: Color.fromARGB(255, 97, 166, 171),
            unselectedLabelColor: Colors.black
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