import 'package:flutter/material.dart';
import 'package:waitron_app/models/Models.dart';
import 'package:waitron_app/screens/OrderList.dart';
import 'package:waitron_app/services/NotificationService.dart';
import 'package:waitron_app/services/db.dart';

// Page enables waitron to manage orders
class WaitronPage extends StatefulWidget  {
  const WaitronPage({super.key});
  
  @override
  WaitronPageState createState() => WaitronPageState();
}

class WaitronPageState extends State<WaitronPage> {
  
  // Listens for changes in orders to send notifications
  @override
  void initState() {
    super.initState();
    DBs().listenToOrders((List<Orders> orders) {
      checkForNewPlacedOrder(orders);
    });
  }

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

  // Checks status of orders in the list to send out notifications
  void checkForNewPlacedOrder(List<Orders> orders) {
    for (Orders order in orders) {
      if (order.status == 'Completed'  && order.notificationStatus != "CompletedNotification") {
        NotificationService().showNotification("Order Completed", "Order for table ${order.table} has been completed.");
        DBs().updateNotificationStatus(order.id, "CompletedNotification");
        break;
      }
    }
  }
}