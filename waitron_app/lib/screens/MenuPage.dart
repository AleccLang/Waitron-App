import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:waitron_app/models/Models.dart';
import 'package:waitron_app/services/db.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  MenuPageState createState() => MenuPageState();
}

class MenuPageState extends State<MenuPage> {
  final TextEditingController itemCodeEntry = TextEditingController();
  final TextEditingController itemDescriptionEntry = TextEditingController();
  final TextEditingController itemPriceEntry = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding:  const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Menu:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Items on the menu
            Expanded(
              child: StreamBuilder(
                stream: DBs().getItemStream(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    List<Item> items = snapshot.data!.docs
                        .map((doc) => Item.fromJson(doc.data() as Map<String, dynamic>))
                        .toList();

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                              // Upodates item price / delete item from menu
                              itemOptions(context, items[index]);
                          },
                        // Display each item in the list
                        child: ListTile(
                          title: Text('${items[index].description} - R${items[index].price}'),
                          subtitle: Text('Item code - ${items[index].code}'),
                        ),
                        );
                      },
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Adds item to menu
                addItemOptions(context);
              },
              child: const Text('Add item'),
            ),
          ],
        ),
      ),
    );
  }

  // Controls popup to add an item to the menu
  void addItemOptions(BuildContext context){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Item Price'),
          content: Column( mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: itemCodeEntry,
              decoration: const InputDecoration(labelText: 'Item Code'),
            ),
            TextField(
              controller: itemDescriptionEntry,
              decoration: const InputDecoration(labelText: 'Item Description'),
            ),
            TextField(
              controller: itemPriceEntry,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Item Price'),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    setState(() {
                      Navigator.pop(context);
                    });
                    itemCodeEntry.clear();
                    itemDescriptionEntry.clear();
                    itemPriceEntry.clear();
                  },
                  child: const Text('Add Item'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

  // Controls popup to update item price / delete item
  void itemOptions(BuildContext context, Item item) {
    showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Update Item'),
        content: Column( mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
            controller: itemPriceEntry,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Item Price'),
            ),
            const SizedBox(height: 16.0),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: (){
                    // Update an item's price
                    DBs().updatePrice(
                      item.code,
                      int.tryParse(itemPriceEntry.text) ?? 0,
                    );
                    itemPriceEntry.clear();
                    Navigator.pop(context);
                    },
                    child: const Text('Update price'),
                  ),
                ElevatedButton(
                  onPressed: () {
                    // Delete an item from the menu
                    DBs().deleteItem(
                      Item(
                        code: item.code,
                        description: item.description,
                        price: 0,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Delete Item'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
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
