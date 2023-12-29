import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:waitron_app/models/Models.dart';
import 'package:waitron_app/services/db.dart';

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
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  title: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('  Table: ${orders[index].table}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.black)),
                          Text('  Status: ${orders[index].status}', style: const TextStyle(color: Color.fromARGB(255, 97, 96, 96), fontSize: 14.0))
                          ]
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.add_circle_rounded, size: 35, color: Color.fromARGB(255, 125, 164, 129)),
                            SizedBox(width: 10)
                          ]
                        )
                      ])
                    ),
                  )
                )
              );
            },
          );
        },
      );
    }

  // Shows an order's details and controls the actions taken on an order in the list
  static void orderOptions(BuildContext context, Orders order, bool waitron) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 125, 164, 129),
          content: Column( mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(order.status == 'Requested')
              const Text('Order Request', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black)),
            if(order.status == 'Placed')
              const Text('Begin Order', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black)),
            if(order.status == 'In Progress')
              const Text('Finish Order', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black)),
            if(order.status == 'Completed' && waitron == true)
              const Text('Deliver Order', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black)),
            if(order.status == 'Completed' && waitron == false)
              const Text('Collect Order', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black)),
            if(order.status == 'Collected')
              const Text('Order', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black)),
            if(order.status == 'Delivered')
              const Text('Order', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 15.0),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(text: 'Table:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0,color: Colors.black)),
                  TextSpan(text: '   ${order.table}',style: const TextStyle(fontSize: 16.0,color: Colors.black)),
                ],
              ),
            ),
            const SizedBox(height: 5.0),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(text: 'Status:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0,color: Colors.black)),
                  TextSpan(text: ' ${order.status}',style: const TextStyle(fontSize: 16.0,color: Colors.black)),
                ],
              ),
            ),
            const SizedBox(height: 5.0),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(text: 'Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0,color: Colors.black))
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: order.requests.map((request) {
                return Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '          ${request.quantity} x ${request.item} (${request.notes})', style: const TextStyle(fontSize: 16.0,color: Colors.black))
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 15.0),
            if (order.status == 'Requested' && waitron == true)  // Customer approves/rejects the order request
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton( // Approve order
                    onPressed: () {
                      DBs().updateOrderStatus(order.id, 'Placed');
                      Navigator.pop(context);
                    },
                    alignment: AlignmentDirectional.bottomEnd,
                    icon: const Icon(Icons.check_circle, size: 50, color: Color.fromARGB(255,255,187,85)),
                  ),
                  IconButton( // Reject order
                    onPressed: () {
                      DBs().updateOrderStatus(order.id, 'Rejected');
                      Navigator.pop(context);
                    },
                    alignment: AlignmentDirectional.bottomEnd,
                    icon: const Icon(Icons.cancel, size: 50, color: Color.fromARGB(255,255,187,85)),
                  ),
                ],
              ),
            if (order.status == 'Requested' && waitron == false) // Customer updates/cancels their order request
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton( // Customer cancels order
                    onPressed: () {
                      DBs().deleteOrder(order);
                      Navigator.pop(context);
                    },
                    alignment: AlignmentDirectional.bottomEnd,
                    icon: const Icon(Icons.delete, size: 50, color: Color.fromARGB(255,255,187,85)),
                  ),
                ],
              ),
            if (order.status == 'Placed'  && waitron == true)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton( // Start work on the order
                    onPressed: () {
                      DBs().updateOrderStatus(order.id, 'In Progress');
                      Navigator.pop(context);
                    },
                    alignment: AlignmentDirectional.bottomEnd,
                    icon: const Icon(Icons.check_circle, size: 50, color: Color.fromARGB(255,255,187,85)),
                  ),
                ],
              ),
            if (order.status == 'In Progress'  && waitron == true) // Finish the order
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      DBs().updateOrderStatus(order.id, 'Completed');
                      Navigator.pop(context);
                    },
                    alignment: AlignmentDirectional.bottomEnd,
                    icon: const Icon(Icons.check_circle, size: 50, color: Color.fromARGB(255,255,187,85)),
                  ),
                ],
              ),
            if (order.status == 'Completed' && waitron == false) // Customer collects the order
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton( // Collect the order
                    onPressed: () {
                      DBs().updateOrderStatus(order.id, 'Collected');
                      Navigator.pop(context);
                    },
                    alignment: AlignmentDirectional.bottomEnd,
                    icon: const Icon(Icons.check_circle, size: 50, color: Color.fromARGB(255,255,187,85)),
                  ),
                ],
              ),
            if (order.status == 'Completed' && waitron == true) // Waitron collects the order
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton( // Deliver the order
                    onPressed: () {
                      DBs().updateOrderStatus(order.id, 'Delivered');
                      Navigator.pop(context);
                    },
                    alignment: AlignmentDirectional.bottomEnd,
                    icon: const Icon(Icons.check_circle, size: 50, color: Color.fromARGB(255,255,187,85)),
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
