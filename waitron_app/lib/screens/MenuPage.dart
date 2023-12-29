import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:waitron_app/models/Models.dart';
import 'package:waitron_app/services/db.dart';

// Page controls the addition and modification of items in the menu
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
      backgroundColor: const Color.fromARGB(255,85,114,88),
      appBar: AppBar(toolbarHeight: 30.0, backgroundColor: const Color.fromARGB(255,85,114,88)),
      body: Padding(
        padding:  const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Menu:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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
                          title: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${String.fromCharCode(0x2022)} ${items[index].description} - R${items[index].price}', style: const TextStyle(color: Colors.black)),
                                Text('   Item code - ${items[index].code}', style: const TextStyle(color: Colors.black, fontSize: 13.0))
                              ])
                            ),
                          )
                        );
                      },
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
            IconButton( // Adds item to menu
              alignment: AlignmentDirectional.bottomEnd,
              icon: const Icon(Icons.add_circle_rounded, size: 35, color: Color.fromARGB(255,255,187,85)),
              onPressed: () {
                addItemOptions(context);
              },
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
          backgroundColor: const Color.fromARGB(255, 125, 164, 129),
          title: const Text('Update Item Price'),
          content: Column( mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: itemCodeEntry,
              decoration: const InputDecoration(labelText: 'Item Code',
                labelStyle: TextStyle(
                  color: Colors.black), 
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
              ),
              cursorColor: const Color.fromARGB(255,255,187,85)
            ),
            TextField(
              controller: itemDescriptionEntry,
              decoration: const InputDecoration(labelText: 'Item Description',
                labelStyle: TextStyle(
                  color: Colors.black), 
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black))
              ),
              cursorColor: const Color.fromARGB(255,255,187,85)
            ),
            TextField(
              controller: itemPriceEntry,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Item Price',
                labelStyle: TextStyle(
                  color: Colors.black), 
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black))
              ),
              cursorColor: const Color.fromARGB(255,255,187,85)
            ),
            const SizedBox(height: 16.0),
            IconButton( // Add an item to the menu
              onPressed: () {
                if (itemCodeEntry.text.isEmpty || itemDescriptionEntry.text.isEmpty || itemPriceEntry.text.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please complete all fields')
                    ),
                  );
                }
                else {
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
                }
              },
              alignment: AlignmentDirectional.bottomEnd,
              icon: const Icon(Icons.add_circle_rounded, size: 35, color: Color.fromARGB(255,255,187,85)),
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
        backgroundColor: const Color.fromARGB(255, 125, 164, 129),
        title: const Text('Update Item'),
        content: Column( mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
            controller: itemPriceEntry,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Item Price',
                labelStyle: TextStyle(
                  color: Colors.black), 
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black))
              ),
              cursorColor: const Color.fromARGB(255,255,187,85)
            ),
            const SizedBox(height: 16.0),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                IconButton( // Update an item's price
                  onPressed: (){
                    if (itemPriceEntry.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a price.'),
                        ),
                      );
                    } else {
                      DBs().updatePrice(
                        item.code,
                        int.tryParse(itemPriceEntry.text) ?? 0,
                      );
                      itemPriceEntry.clear();
                      Navigator.pop(context);
                    }
                    },
                    alignment: AlignmentDirectional.bottomEnd,
                    icon: const Icon(Icons.check_circle, size: 35, color: Color.fromARGB(255,255,187,85)),
                  ),
                IconButton( // Delete an item from the menu
                  onPressed: () {
                    DBs().deleteItem(
                      Item(
                        code: item.code,
                        description: item.description,
                        price: 0,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  alignment: AlignmentDirectional.bottomEnd,
                  icon: const Icon(Icons.delete, size: 35, color: Color.fromARGB(255,255,187,85)),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  alignment: AlignmentDirectional.bottomEnd,
                  icon: const Icon(Icons.cancel, size: 35, color: Color.fromARGB(255,255,187,85)),
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
