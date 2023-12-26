import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waitron_app/models/Models.dart';
import 'package:waitron_app/services/db.dart';

class WaitronPage extends StatelessWidget {
  const WaitronPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Requests'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrderList(status: 'Requested'),
            OrderList(status: 'Completed'),
          ],
        ),
      ),
    );
  }
}

// Builds and outputs list of Orders depending on their status
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
                  orderOptions(context, orders[index]);
              },
              child: ListTile(
                title: Text('Table: ${orders[index].table}'),
                subtitle: Text('Status: ${orders[index].status}'),
              ),
            );
          },
        );
      },
    );
  }

  // Shows an orders details and controls the actions taken on an order in the list.
  void orderOptions(BuildContext context, Orders order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column( mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Table: ${order.table}', style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text('Status: ${order.status}', style: const TextStyle(fontSize: 16.0)),
            const SizedBox(height: 15.0),
            const Text('Items:', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: order.requests.map((request) {
                return Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text('${request.quantity} x ${request.item} (${request.notes})')
                );
              }).toList(),
            ),
            const SizedBox(height: 15.0),
            if (order.status == 'Requested')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Approve order
                      // ***** Notify customer *****
                      DBs().updateOrderStatus(order.id, 'Placed');
                      Navigator.pop(context);
                    },
                    child: const Text('Approve'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Reject order
                      // ***** Notify customer *****
                      DBs().deleteOrder(order);
                      Navigator.pop(context);
                    },
                    child: const Text('Reject'),
                  ),
                ],
              ),
            if (order.status == 'Placed')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Start work on the order
                      DBs().updateOrderStatus(order.table, 'In Progress');
                      Navigator.pop(context);
                    },
                    child: const Text('Begin Order'),
                  ),
                ],
              ),
            if (order.status == 'In Progress')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Finish the order
                      // ***** Notify waitron *****
                      DBs().updateOrderStatus(order.table, 'Completed');
                      Navigator.pop(context);
                    },
                    child: const Text('Finish Order'),
                  ),
                ],
              ),
            if (order.status == 'Completed')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Deliver the order
                      DBs().updateOrderStatus(order.table, 'Delivered');
                      Navigator.pop(context);
                    },
                    child: const Text('Deliver Order'),
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
