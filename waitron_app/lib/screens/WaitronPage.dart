import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waitron_app/models/Models.dart';
import 'package:waitron_app/services/db.dart';

class WaitronPage extends StatelessWidget {
  const WaitronPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrderList(),
    );
  }
}

class OrderList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: DBs().getOrderStream(),
      builder: (context, snapshot) {
        List<Orders> orders = snapshot.data!.docs.map((DocumentSnapshot doc) {
          return Orders.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                _showOrderOptions(context, orders[index]);
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

  void _showOrderOptions(BuildContext context, Orders order) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Approve order 
                      DBs().updateOrderStatus(order.table, 'Placed');
                      Navigator.pop(context);
                    },
                    child: Text('Approve Order'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Reject order
                      DBs().deleteOrder(order);
                      Navigator.pop(context);
                    },
                    child: Text('Reject Order'),
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
