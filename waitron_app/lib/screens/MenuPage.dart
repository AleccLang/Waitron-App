import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:waitron_app/models/Models.dart';
import 'package:waitron_app/services/db.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController itemCodeEntry = TextEditingController();
  final TextEditingController itemDescriptionEntry = TextEditingController();
  final TextEditingController itemPriceEntry = TextEditingController();

  bool visible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                // Toggle the visibility of menu item entry.
                setState(() {
                  visible = !visible;
                });
              },
              child: Text(visible ? 'Hide' : 'Add/Update item'),
            ),
            Visibility(
              visible: visible,
              child: Column(
                children: [
                  TextField(
                    controller: itemCodeEntry,
                    decoration: InputDecoration(labelText: 'Item Code'),
                  ),
                  TextField(
                    controller: itemDescriptionEntry,
                    decoration: InputDecoration(labelText: 'Item Description'),
                  ),
                  TextField(
                    controller: itemPriceEntry,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Item Price'),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: visible,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add an item to the menu
                      DBs().addItem(
                        Item(
                          code: itemCodeEntry.text,
                          description: itemDescriptionEntry.text,
                          price: int.tryParse(itemPriceEntry.text) ?? 0,
                        ),
                      );
                      itemCodeEntry.clear();
                      itemDescriptionEntry.clear();
                      itemPriceEntry.clear();
                    },
                    child: Text('Add Item'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Update an item's price
                      DBs().updatePrice(
                        itemCodeEntry.text,
                        int.tryParse(itemPriceEntry.text) ?? 0,
                      );
                      itemCodeEntry.clear();
                      itemDescriptionEntry.clear();
                      itemPriceEntry.clear();
                    },
                    child: Text('Update price'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Delete an item from the menu
                      DBs().deleteItem(
                        Item(
                          code: itemCodeEntry.text,
                          description: itemDescriptionEntry.text,
                          price: int.tryParse(itemPriceEntry.text) ?? 0,
                        ),
                      );
                      itemCodeEntry.clear();
                      itemDescriptionEntry.clear();
                      itemPriceEntry.clear();
                    },
                    child: Text('Delete Item'),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            
            // Items on the menu
            Text(
              'Menu:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder(
                stream: DBs().getItemStream(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    // Maps the docs to a list of Item objects
                    List<Item> items = snapshot.data!.docs
                        .map((doc) => Item.fromJson(doc.data() as Map<String, dynamic>))
                        .toList();

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        // Display each item in the list
                        return ListTile(
                          title: Text('${items[index].description} - R${items[index].price}'),
                          subtitle: Text('Item code - ${items[index].code}'),
                        );
                      },
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
