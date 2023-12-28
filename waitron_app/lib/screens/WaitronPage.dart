import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waitron_app/models/Models.dart';
import 'package:waitron_app/services/db.dart';
import 'package:waitron_app/services/NotificationService.dart';

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

// Builds and outputs a list of Orders depending on their status
class OrderList extends StatelessWidget {
  final String status;
  const OrderList({super.key, required this.status});
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: DBs().getOrderStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        List<Orders> orders = snapshot.data!.docs
        .where((doc) => doc['status'] == status)
        .map((DocumentSnapshot doc) {
          return Orders.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                  orderOptions(context, orders[index], true);
              },
              child: ListTile(
                title: Text('${String.fromCharCode(0x2022)} Table: ${orders[index].table}', style: const TextStyle(color: Colors.black)),
                subtitle: Text('   Status: ${orders[index].status}', style: const TextStyle(color: Colors.black)),
              ),
            );
          },
        );
      },
    );
  }

  // Shows an order's details and controls the actions taken on an order in the list.
  static void orderOptions(BuildContext context, Orders order, bool waitron) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255,246,246,233),
          content: Column( mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Table: ${order.table}', style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8.0),
            Text('Status: ${order.status}', style: const TextStyle(fontSize: 16.0, color: Colors.black)),
            const SizedBox(height: 15.0),
            const Text('Items:', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: order.requests.map((request) {
                return Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text('${request.quantity} x ${request.item} (${request.notes})', style: const TextStyle(color: Colors.black))
                );
              }).toList(),
            ),
            const SizedBox(height: 15.0),
            if (order.status == 'Requested' && waitron == true)  // Customer approves/rejects the order request
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton( // Approve order
                    onPressed: () {
                      // Send notification
                      NotificationService().showNotification("Order Approved", "Order for table ${order.table} has been approved.");
                      DBs().updateOrderStatus(order.id, 'Placed');
                      Navigator.pop(context);
                    },
                     style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                      ),
                    ),
                    child: const Text('Approve', style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton( // Reject order
                    onPressed: () {
                      // Send notification
                      NotificationService().showNotification("Order Rejected", "Order for table ${order.table} has been rejected.");
                      DBs().deleteOrder(order);
                      Navigator.pop(context);
                    },
                     style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                      ),
                    ),
                    child: const Text('Reject', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            if (order.status == 'Requested' && waitron == false) // Customer updates/cancels their order request
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton( // Customer cancels order
                    onPressed: () {
                      DBs().deleteOrder(order);
                      Navigator.pop(context);
                    },
                     style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                ),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            if (order.status == 'Placed'  && waitron == true)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton( // Start work on the order
                    onPressed: () {
                      DBs().updateOrderStatus(order.id, 'In Progress');
                      Navigator.pop(context);
                    },
                     style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                ),
                    ),
                    child: const Text('Begin Order', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            if (order.status == 'In Progress'  && waitron == true) // Finish the order
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Send notification
                      NotificationService().showNotification("Order Completed", "Order for table ${order.table} has been completed");
                      DBs().updateOrderStatus(order.id, 'Completed');
                      Navigator.pop(context);
                    },
                     style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                      ),
                    ),
                    child: const Text('Finish Order', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            if (order.status == 'Completed' && waitron == false) // Customer collects the order
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Collect the order
                      DBs().updateOrderStatus(order.id, 'Collected');
                      Navigator.pop(context);
                    },
                     style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                      ),
                    ),
                    child: const Text('Collect Order', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            if (order.status == 'Completed' && waitron == true) // Waitron collects the order
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Deliver the order
                      DBs().updateOrderStatus(order.id, 'Delivered');
                      Navigator.pop(context);
                    },
                     style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                      ),
                    ),
                    child: const Text('Deliver Order', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
