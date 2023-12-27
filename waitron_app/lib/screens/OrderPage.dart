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
        backgroundColor: const Color.fromARGB(255,97,166,171),
        appBar: AppBar(
          toolbarHeight: 9.0,
          backgroundColor: const Color.fromARGB(255,246,246,233),
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text(
                  'Place Order',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Tab(
                child: Text(
                  'Table Orders',
                  style: TextStyle(color: Colors.black),
                ),
              )
            ],
            indicatorColor: Color.fromARGB(255, 97, 166, 171),
            labelColor: Color.fromARGB(255, 97, 166, 171),
            unselectedLabelColor: Colors.black
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 246, 246, 233),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    )
                  ),
                  child: const Text('Add to Order',  style: TextStyle(color: Colors.black)),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 246, 246, 233),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    )
                  ),
                  child: const Text('Request Order',  style: TextStyle(color: Colors.black)),
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
          backgroundColor: const Color.fromARGB(255,246,246,233),
          title: const Text('Item Options',  style: TextStyle(color: Colors.black)),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 246, 246, 233),
                  shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                  )
                ),
                child: const Text('Remove',  style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton( // Update the item
                onPressed: () {
                  Navigator.pop(context);
                  updateItem(context, index);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 246, 246, 233),
                  shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                  )
                ),
                child: const Text('Update',  style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton( // Cancel
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 246, 246, 233),
                  shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                  )
                ),
                child: const Text('Cancel',  style: TextStyle(color: Colors.black)),
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
          backgroundColor: const Color.fromARGB(255,246,246,233),
          title: const Text('Update Item',  style: TextStyle(color: Colors.black)),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 246, 246, 233),
                shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                ),
              ),
              child: const Text('Update item',  style: TextStyle(color: Colors.black)),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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
                        title: Text('Table: ${orders[index].table}',  style: TextStyle(color: Colors.black)),
                        subtitle: Text('Status: ${orders[index].status}',  style: TextStyle(color: Colors.black)),
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
          backgroundColor: const Color.fromARGB(255,246,246,233),
          title: const Text('Add Item',  style: TextStyle(color: Colors.black)),
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
                    dropdownColor: const Color.fromARGB(255,246,246,233),
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
                    decoration: const InputDecoration(labelText: 'Select Item',
                      labelStyle: TextStyle(
                        color: Colors.black), 
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black))
                    ),
                  );
                } 
                else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            TextField(
              controller: notesEntry,
              decoration: const InputDecoration(labelText: 'Notes',
                labelStyle: TextStyle(
                  color: Colors.black), 
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black))
              ),
            ),
            TextField(
              controller: quantityEntry,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity',
                labelStyle: TextStyle(
                  color: Colors.black), 
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black))
              )
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 246, 246, 233),
                shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                ),
              ),
              child: const Text('Add to Order', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      );
    },
  );
  }
}
