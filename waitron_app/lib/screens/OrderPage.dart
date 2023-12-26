import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waitron_app/models/Models.dart';
import 'package:waitron_app/services/db.dart';

class OrderPage extends StatefulWidget {
  final tableNumber;

  const OrderPage({super.key, required this.tableNumber});

  @override
  OrderPageState createState() => OrderPageState(tableNumber);
}

class OrderPageState extends State<OrderPage> {
  final String tableNumber;
  final TextEditingController notesEntry = TextEditingController();
  final TextEditingController quantityEntry = TextEditingController();

  List<Request> orderRequests = [];
  Item? selectedMenuItem;
  
  OrderPageState(this.tableNumber);

  // Inits the item list and sets the selected item to default to the first
  @override
  void initState() {
    super.initState();
    DBs().getItemStream().first.then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        List<Item> items = snapshot.docs
            .map((doc) => Item.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
        setState(() {
          selectedMenuItem = items.first; 
        });
      }
    });
  }
    @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Page'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Place Order'),
              Tab(text: 'Table Orders'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            createOrderTab(context),
            listOrdersTab(context),
          ],
        ),
      ),
    );
  }

  // Tab to create an order for the table
  Widget createOrderTab(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // List of items in the order
            const Text(
              'Order:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: orderRequests.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(orderRequests[index].item),
                    subtitle: Text(
                        'Notes: ${orderRequests[index].notes}, Quantity: ${orderRequests[index].quantity}'),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Request the order
                    addItemToOrder(context);
                  },
                  child: const Text('Add item to Order'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Request the order
                    DBs().addOrder(
                      Orders(
                        id: "",
                        table: tableNumber,
                        requests: orderRequests,
                        status: 'Requested',
                        time: Timestamp.now(),
                      ),
                    );
                    setState(() {
                      orderRequests = [];
                    });
                  },
                  child: const Text('Request Order'),
                ),
              ],
            ),
          ],
        ),
      );
    }

  // Tab to list all orders for the table
  Widget listOrdersTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Order Requests:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child:StreamBuilder<QuerySnapshot>(
              stream: DBs().getOrderStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                List<Orders> orders = snapshot.data!.docs
                .where((doc) => doc['table'] == tableNumber)
                .map((DocumentSnapshot doc) {
                  return Orders.fromJson(doc.data() as Map<String, dynamic>);
                }).toList();

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                          collectOrder(context, orders[index]);
                      },
                      child: ListTile(
                        title: Text('Table: ${orders[index].table}'),
                        subtitle: Text('Status: ${orders[index].status}'),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // Adds an item to the order request
  void addItemToOrder(BuildContext context){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Item'),
          content: Column( mainAxisSize: MainAxisSize.min,
          children: [
            // List of all items on the menu
            StreamBuilder<QuerySnapshot>(
              stream: DBs().getItemStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Item> items = snapshot.data!.docs
                    .map((doc) =>
                    Item.fromJson(doc.data() as Map<String, dynamic>))
                    .toList();

                  return DropdownButtonFormField<Item>(
                    value: selectedMenuItem = items.first,
                    onChanged: (value) {
                      setState(() {
                        selectedMenuItem = value!;
                      });
                    },
                    items: items
                        .map((item) => DropdownMenuItem<Item>(
                          value: item,
                          child: Text(item.description),
                        )).toList(),
                    decoration: const InputDecoration(labelText: 'Select Item'),
                  );
                } 
                else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            TextField(
              controller: notesEntry,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            TextField(
              controller: quantityEntry,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: () {
                // Adds the request to the list
                setState(() {
                  orderRequests.add(Request(
                    item: selectedMenuItem?.description ?? '',
                    notes: notesEntry.text,
                    quantity: int.tryParse(quantityEntry.text) ?? 1,)
                  );
                  Navigator.pop(context);
                  notesEntry.clear();
                  quantityEntry.clear();
                  selectedMenuItem = null;
                });
              },
              child: const Text('Add Item to Order'),
            ),
          ],
        ),
      );
    },
  );
  }

  // Allows user to collect their own order
  void collectOrder(BuildContext context, Orders order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column( mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Table: ${order.table}', style: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold)),
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
            if (order.status == 'Completed')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Collect the order
                      DBs().updateOrderStatus(order.id, 'Collected');
                      Navigator.pop(context);
                    },
                    child: const Text('Collect Order'),
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
