import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:waitron_app/models/Models.dart';
import 'package:waitron_app/screens/OrderList.dart';
import 'package:waitron_app/services/NotificationService.dart';
import 'package:waitron_app/services/db.dart';

// Page enables waitron to manage and place orders
class WaitronPage extends StatefulWidget  {
  const WaitronPage({super.key});
  
  @override
  WaitronPageState createState() => WaitronPageState();
}

class WaitronPageState extends State<WaitronPage> {
  late bool waitronPage; // Keeps track of if the waitron page is being viewed, uses this to ensure notifaction doesnt trigger when viewing other tabs in StaffPage()

  // Sets waitronPage to false when the page is being left
  @override 
  void dispose() {
    waitronPage = false;
    super.dispose();
  }
  
  // Listens for changes in orders to send notifications
  @override
  void initState() {
    super.initState();
    waitronPage = true;
    DBs().listenToOrders((List<Orders> orders) {
      checkForNewPlacedOrder(orders);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255,85,114,88),
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text('Place Order', style: TextStyle(fontSize: 17, color: Colors.black), textAlign: TextAlign.center,),
              ),
              Tab(
                child: Text(
                  'Requests', style: TextStyle(fontSize: 17, color: Colors.black)
                ),
              ),
              Tab(
                child: Text(
                  'Completed', style: TextStyle(fontSize: 17, color: Colors.black)
                ),
              )
            ],
            overlayColor: MaterialStatePropertyAll(Color.fromARGB(255, 255, 239, 216)),
            indicatorColor: Color.fromARGB(255,255,187,85),
            labelColor: Color.fromARGB(255,255,187,85),
            unselectedLabelColor: Colors.black
          ),
        ),
        body: const TabBarView(
          children: [
            PlaceOrderTab(), // Tab for waitron to place an order for a table
            OrderList(status: 'Requested'), // List of orders with the status 'Requested'
            OrderList(status: 'Completed'), // List of orders with the status 'Completed'
          ],
        ),
      ),
    );
  }

  // Checks status of orders in the list to send out notifications
  void checkForNewPlacedOrder(List<Orders> orders) {
    for (Orders order in orders) {
      if (order.status == 'Completed'  && order.notificationStatus != "CompletedNotification" && waitronPage == true) {
        NotificationService().showNotification("Order Completed", "Order for table ${order.table} has been completed.");
        DBs().updateNotificationStatus(order.id, "CompletedNotification");
        break;
      }
    }
  }
}

// Provides the waitron functionality to place an order
class PlaceOrderTab extends StatefulWidget {
  const PlaceOrderTab({super.key});

  @override
  PlaceOrderTabState createState() => PlaceOrderTabState();
}

class PlaceOrderTabState extends State<PlaceOrderTab> {
  List<Request> orderRequests = [];
  Item? selectedMenuItem;
 final TextEditingController notesEntry = TextEditingController();
  final TextEditingController quantityEntry = TextEditingController();
  final TextEditingController tableNumEntry = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 85, 114, 88),
      body: createOrderTab(context)
    );
  }

  // Widget to place an order for a table
  Widget createOrderTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 125, 164, 129),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
            ),
            child: const Center(
              child: Text('Order:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: orderRequests.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    itemOptions(context, index);
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
                            Text(' ${orderRequests[index].item}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.black)),
                            Text(' Notes: ${orderRequests[index].notes}, Quantity: ${orderRequests[index].quantity}', style: const TextStyle(color: Color.fromARGB(255, 97, 96, 96), fontSize: 14.0))
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
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded( // Textbox for Table Number entry
                child: SizedBox(
                  child: TextField(
                    controller: tableNumEntry,
                    decoration: 
                      const InputDecoration(labelText: 'Table Number', 
                        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.black), 
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black))
                      ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black),
                    cursorColor: const Color.fromARGB(255, 0, 0, 0)
                  ),
                ),  
              ),
              IconButton(
                onPressed: () {
                  addItemToOrder(context);
                },
                icon: const Icon(Icons.add_circle_rounded, size: 50, color: Color.fromARGB(255,255,187,85)),
              ),
              IconButton(
                onPressed: () async {
                  if (tableNumEntry.text.isEmpty) { // Error msg if no table num is entered
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a table number.')
                      ),
                    );
                  }
                  if (orderRequests.isEmpty) { // Error msg if no items are added
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please add items to the order.'),
                      ),
                    );
                  }
                  bool active = await DBs().isTableActive(Tables(tableNumber: tableNumEntry.text));
                  if (active){ // Error msg to notify the table is already in use
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Table ${tableNumEntry.text} is already in use.')
                      ),
                    );
                  }
                  if (!active && tableNumEntry.text.isNotEmpty && orderRequests.isNotEmpty){
                    DBs().addOrder(
                      Orders(
                        id: "",
                        table: tableNumEntry.text,
                        requests: orderRequests,
                        status: 'Placed',
                        time: Timestamp.now(),
                        notificationStatus: "default",
                      ),
                    );  
                    setState(() {
                      orderRequests = [];
                    });
                    FocusScope.of(context).unfocus();
                  }
                },
                icon: const Icon(Icons.arrow_circle_right, size: 50, color: Color.fromARGB(255,255,187,85)),
              ),
            ]
          )
        ],
      ),
    );
  }

  // Remove or update item in the order
  void itemOptions(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 125, 164, 129),
          title: const Text('Item Options',  style: TextStyle(color: Colors.black)),
          content: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 9),
                  ElevatedButton( // Update the item
                    onPressed: () {
                      Navigator.pop(context);
                      updateItem(context, index);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(25, 35),
                      backgroundColor: const Color.fromARGB(255,255,187,85),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                      ),
                    ),
                    child: const Text('Update', style: TextStyle(color: Colors.black)),
                  ),
                ]
              ),
              IconButton( // Remove the item
                onPressed: () {
                  setState(() {
                    orderRequests.removeAt(index);
                  });
                  Navigator.pop(context);
                },
                alignment: AlignmentDirectional.bottomEnd,
                icon: const Icon(Icons.delete, size: 50, color: Color.fromARGB(255,255,187,85)),
              ),
              IconButton( // Cancel
                onPressed: () {
                  Navigator.pop(context);
                },
                alignment: AlignmentDirectional.bottomEnd,
                icon: const Icon(Icons.cancel, size: 50, color: Color.fromARGB(255,255,187,85)),
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
          backgroundColor: const Color.fromARGB(255, 125, 164, 129),
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
                          child: Text('${item.description} - R${item.price}'),
                        )).toList(),
                    decoration: const InputDecoration(labelText: 'Select Item',
                      labelStyle: TextStyle(
                        color: Colors.black), 
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black))),
                  );
                } 
                else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            TextField(
              controller: currentNotes,
              decoration: const InputDecoration(labelText: 'Notes',
                labelStyle: TextStyle(
                  color: Colors.black), 
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black))),
              cursorColor: const Color.fromARGB(255,255,187,85)
            ),
            TextField(
              controller: currentQuantity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity',
                labelStyle: TextStyle(
                  color: Colors.black), 
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black))),
              cursorColor: const Color.fromARGB(255,255,187,85)
            ),
            const SizedBox(height: 15.0),
            IconButton( // Adds the updated item to the request
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
              alignment: AlignmentDirectional.bottomEnd,
              icon: const Icon(Icons.check_circle, size: 50, color: Color.fromARGB(255,255,187,85)),
            ),
          ],
        ),
      );
    },
  );
  }

  // Adds an item to the order
  void addItemToOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 125, 164, 129),
          title: const Text('Add Item', style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
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
                      dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                      value: selectedMenuItem = items.first,
                      onChanged: (value) {
                        setState(() {
                          selectedMenuItem = value!;
                        });
                      },
                      items: items
                          .map((item) => DropdownMenuItem<Item>(
                        value: item,
                        child: Text('${item.description} - R${item.price}'),
                      ))
                          .toList(),
                      decoration: const InputDecoration(
                          labelText: 'Select Item',
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black))),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              TextField(
                controller: notesEntry,
                decoration: const InputDecoration(
                    labelText: 'Notes',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black))),
                cursorColor: const Color.fromARGB(255, 255, 187, 85),
              ),
              TextField(
                controller: quantityEntry,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Quantity',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black))),
                cursorColor: const Color.fromARGB(255, 255, 187, 85),
              ),
              const SizedBox(height: 15.0),
              IconButton( // Adds the item to the request
                onPressed: () {
                  setState(() {
                    orderRequests.add(Request(
                      item: selectedMenuItem?.description ?? '',
                      notes: notesEntry.text,
                      quantity: int.tryParse(quantityEntry.text) ?? 1,
                    ));
                    Navigator.pop(context);
                    notesEntry.clear();
                    quantityEntry.clear();
                    selectedMenuItem = null;
                  });
                },
                alignment: Alignment.bottomRight,
                icon: const Icon(Icons.add_circle_rounded,
                    size: 50, color: Color.fromARGB(255, 255, 187, 85)),
              ),
            ],
          ),
        );
      },
    );
  }
}
