import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waitron_app/models/Models.dart';
import 'package:waitron_app/services/db.dart';

class WaitronPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: 'Requests'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OrderList(status: 'Requested'),
            OrderList(status: 'Completed'),
          ],
        ),
      ),
    );
  }
}

class OrderList extends StatelessWidget {
  final String status;
  const OrderList({Key? key, required this.status}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: DBs().getOrderStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
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

  void orderOptions(BuildContext context, Orders order) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Table: ${order.table}', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.0),
              Text('Status: ${order.status}', style: TextStyle(fontSize: 16.0)),
              SizedBox(height: 16.0),
              Text('Items:', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: order.requests.map((request) {
                  return Text('${request.quantity} x ${request.item} (${request.notes})');
                }).toList(),
              ),
              SizedBox(height: 16.0),
              if (order.status == 'Requested')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Approve order
                        // ***** Notify customer *****
                        DBs().updateOrderStatus(order.table, 'Placed');
                        Navigator.pop(context);
                      },
                      child: Text('Approve Order'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Reject order
                        // ***** Notify customer *****
                        DBs().deleteOrder(order);
                        Navigator.pop(context);
                      },
                      child: Text('Reject Order'),
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
                      child: Text('Begin Order'),
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
                        DBs().updateOrderStatus(order.table, 'Completed');
                        Navigator.pop(context);
                      },
                      child: Text('Finish Order'),
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
                      child: Text('Deliver Order'),
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
