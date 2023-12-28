import 'package:flutter/material.dart';
import 'package:waitron_app/screens/OrderList.dart';

// Page enables waitron to manage orders
class WaitronPage extends StatelessWidget {
  const WaitronPage({super.key});

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
                  'Requests',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Tab(
                child: Text(
                  'Completed',
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
            OrderList(status: 'Requested'), // List of orders with the status 'Requested'
            OrderList(status: 'Completed'), // List of orders with the status 'Completed'
          ],
        ),
      ),
    );
  }
}