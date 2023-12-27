import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waitron_app/models/Models.dart';
import 'package:waitron_app/services/db.dart';
import 'package:waitron_app/screens/WaitronPage.dart';

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

  // Tab to create an order request for the table
  Widget createOrderTab(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Order:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: orderRequests.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      itemOptions(context, index);
                    },
                    child: ListTile(
                        title: Text(orderRequests[index].item),
                        subtitle: Text(
                            'Notes: ${orderRequests[index].notes}, Quantity: ${orderRequests[index].quantity}'),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton( // Adds an item to current order
                  onPressed: () {
                    addItemToOrder(context);
                  },
                  child: const Text('Add item to Order'),
                ),
                ElevatedButton( // Sends order request
                  onPressed: () {
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

  // Remove or update item in current order request
  void itemOptions(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Item Options'),
          content: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: [
              ElevatedButton( // Remove the item
                onPressed: () {
                  setState(() {
                    orderRequests.removeAt(index);
                  });
                  Navigator.pop(context);
                },
                child: const Text('Remove'),
              ),
              ElevatedButton( // Update the item
                onPressed: () {
                  Navigator.pop(context);
                  updateItem(context, index);
                },
                child: const Text('Update'),
              ),
              ElevatedButton( // Cancel
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }


  // Updates the selected item
  void updateItem(BuildContext context, int index) {
    String currentItem = orderRequests[index].item;
    final TextEditingController currentNotes = TextEditingController(text: orderRequests[index].notes);
    final TextEditingController currentQuantity = TextEditingController(text: orderRequests[index].quantity.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Item'),
          content: Column( mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: DBs().getItemStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Item> items = snapshot.data!.docs
                    .map((doc) =>
                    Item.fromJson(doc.data() as Map<String, dynamic>))
                    .toList();

                  return DropdownButtonFormField<Item>(
                    value: selectedMenuItem = items.firstWhere(
                        (item) => item.description == currentItem,
                        orElse: () => items.first),
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
              controller: currentNotes,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            TextField(
              controller: currentQuantity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 15.0),
            ElevatedButton( // Adds the updated item to the request
              onPressed: () {
                setState(() {
                  orderRequests.removeAt(index);
                  orderRequests.add(Request(
                    item: selectedMenuItem?.description ?? '',
                    notes: currentNotes.text,
                    quantity: int.tryParse(currentQuantity.text) ?? 1,)
                  );
                  Navigator.pop(context);
                  notesEntry.clear();
                  quantityEntry.clear();
                  selectedMenuItem = null;
                });
              },
              child: const Text('Update item'),
            ),
          ],
        ),
      );
    },
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
                         OrderList.orderOptions(context, orders[index], false);
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
            ElevatedButton( // Adds the item to the request
              onPressed: () {
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
}
