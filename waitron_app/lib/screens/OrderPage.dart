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
    return Scaffold(
      appBar: AppBar(
      ),
      body: Padding(
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

}
