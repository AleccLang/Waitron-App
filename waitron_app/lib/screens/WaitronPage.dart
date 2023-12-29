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
  late bool waitronPage; // Keeps track of if the waitron page is being viewed, uses this to ensure notifaction doesnt trigger when viewing other tabs in StaffPage()

  // Sets waitronPage to false when the page is being left
  @override 
  void dispose() {
    waitronPage = false;
    super.dispose();
  }
  
  // Listens for changes in orders to send notifications
  @override
  void initState() {
    super.initState();
    waitronPage = true;
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
          toolbarHeight: 30.0,
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text(
                  'Requests', style: TextStyle(fontSize: 20, color: Colors.black)
                ),
              ),
              Tab(
                child: Text(
                  'Completed', style: TextStyle(fontSize: 20, color: Colors.black)
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
      if (order.status == 'Completed'  && order.notificationStatus != "CompletedNotification" && waitronPage == true) {
        NotificationService().showNotification("Order Completed", "Order for table ${order.table} has been completed.");
        DBs().updateNotificationStatus(order.id, "CompletedNotification");
        break;
      }
    }
  }
}