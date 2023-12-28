import 'package:flutter/material.dart';
import 'package:waitron_app/screens/OrderList.dart';

// Page enables kitchen to manage orders
class KitchenPage extends StatelessWidget {
  const KitchenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255,85,114,88),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
            overlayColor: MaterialStatePropertyAll(Color.fromARGB(255, 255, 239, 216)),
            indicatorColor: Color.fromARGB(255,255,187,85),
            labelColor: Color.fromARGB(255,255,187,85),
            unselectedLabelColor: Colors.black
          ),
        ),
        body: const TabBarView(
          children: [
            OrderList(status: 'Placed'), // List of orders with the status 'Placed'
            OrderList(status: 'In Progress'),  // List of orders with the status 'In Progress'
          ],
        ),
      ),
    );
  }
}