import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waitron_app/models/Models.dart';
import 'package:waitron_app/services/db.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController tableNumEntry = TextEditingController();
  final TextEditingController notesEntry = TextEditingController();
  final TextEditingController quantityEntry = TextEditingController();

  bool visible = false;
  List<Request> orderRequests = [];

  Item? selectedMenuItem;

  @override
  void initState() {
    super.initState();
    DBs().getItemStream().first.then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        List<Item> items = snapshot.docs
            .map((doc) => Item.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
        setState(() {
          selectedMenuItem = items.first; // Init with thefirst item in the list
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  visible = !visible;
                });
              },
              child: Text(visible ? 'Hide' : 'Add Item to Order'),
            ),
            if (visible)
              Column(
                children: [
                  // List of all items on the menu
                  StreamBuilder(
                    stream: DBs().getItemStream(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        List<Item> items = snapshot.data!.docs
                            .map((doc) =>
                                Item.fromJson(doc.data() as Map<String, dynamic>))
                            .toList();

                        return DropdownButtonFormField<Item>(
                          value: selectedMenuItem ?? items.first,
                          onChanged: (value) {
                            setState(() {
                              selectedMenuItem = value!;
                            });
                          },
                          items: items
                              .map((item) => DropdownMenuItem<Item>(
                                    value: item,
                                    child: Text(item.description),
                                  ))
                              .toList(),
                          decoration:
                              InputDecoration(labelText: 'Select Item'),
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                  TextField(
                    controller: notesEntry,
                    decoration: InputDecoration(labelText: 'Notes'),
                  ),
                  TextField(
                    controller: quantityEntry,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Quantity'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Adds the request to the list
                      setState(() {
                        orderRequests.add(Request(
                          item: selectedMenuItem?.description ?? '',
                          notes: notesEntry.text,
                          quantity: int.tryParse(quantityEntry.text) ?? 1,
                        ));
                        notesEntry.clear();
                        quantityEntry.clear();
                        selectedMenuItem = null;
                      });
                      setState(() {
                        visible = !visible;
                      });
                    },
                    child: Text('Add Item to Order'),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // List of items in the order
            Text(
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
            TextField(
              controller: tableNumEntry,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Table no.'),
            ),
            ElevatedButton(
              onPressed: () {
                // Request the order
                DBs().addOrder(
                  Orders(
                    table: tableNumEntry.text,
                    requests: orderRequests,
                    status: 'Requested',
                  ),
                );
                tableNumEntry.clear();
                setState(() {
                  orderRequests = [];
                });
              },
              child: Text('Request Order'),
            ),
          ],
        ),
      ),
    );
  }
}
