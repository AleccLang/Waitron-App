import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waitron_app/models/Models.dart';
import 'package:waitron_app/screens/OrderList.dart';
import 'package:waitron_app/services/NotificationService.dart';
import 'package:waitron_app/services/db.dart';

// Page supports the creation of orders, as well as keeping track of all orders for a table
class OrderPage extends StatefulWidget {
  final tableNumber;
  const OrderPage({super.key, required this.tableNumber});
  @override
  OrderPageState createState() => OrderPageState(tableNumber);
}

class OrderPageState extends State<OrderPage> {
  String tableNumber; // Table number for the order
  List<Request> orderRequests = []; // Requests to be added to an order
  Item? selectedMenuItem; // Selected menu item in the drop down
  final TextEditingController notesEntry = TextEditingController();
  final TextEditingController quantityEntry = TextEditingController();

  OrderPageState(this.tableNumber);

  // Removes the active table from the DB when the page is left
  @override 
  void dispose() {
    DBs().deleteActiveTable(Tables(tableNumber: tableNumber));
    tableNumber = "";
    super.dispose();
  }

  // Listens for changes in orders to send notifications
  @override
  void initState() {
    super.initState();
    DBs().listenToOrders((List<Orders> orders) {
      checkForNewPlacedOrder(orders);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255,85,114,88),
        appBar: AppBar(
          toolbarHeight: 30.0,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
            overlayColor: MaterialStatePropertyAll(Color.fromARGB(255, 255, 239, 216)),
            indicatorColor: Color.fromARGB(255,255,187,85),
            labelColor: Color.fromARGB(255,255,187,85),
            unselectedLabelColor: Colors.black
          ),
        ),
        body: TabBarView(
          children: [
            createOrderTab(context), // Widget for creating an order request
            listOrdersTab(context), // Widget for listing all orders for the table
          ],
        ),
      ),
    );
  }

  // Checks status of orders in the list to send out notifications
  void checkForNewPlacedOrder(List<Orders> orders) {
    for (Orders order in orders) {
      if (order.status == 'Placed' && order.table == tableNumber && order.notificationStatus != "ApprovedNotification") {
        NotificationService().showNotification("Order Approved", "Order for table ${order.table} has been approved.");
        DBs().updateNotificationStatus(order.id, "ApprovedNotification");
        break;
      }
      if (order.status == 'Rejected' && order.table == tableNumber && order.notificationStatus != "RejectedNotification") {
        NotificationService().showNotification("Order Rejected", "Order for table ${order.table} has been rejected.");
        DBs().deleteOrder(order);
        break;
      }
    }
  }

  // Widget to create an order request for the table
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
                      title: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${String.fromCharCode(0x2022)} ${orderRequests[index].item}'),
                            Text('   Notes: ${orderRequests[index].notes}, Quantity: ${orderRequests[index].quantity}', style: const TextStyle(color: Colors.black, fontSize: 13.0))
                          ])
                        ),
                      )
                    );
                  },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton( // Adds an item to current order
                  alignment: AlignmentDirectional.bottomEnd,
                  icon: const Icon(Icons.add_circle_rounded, size: 35, color: Color.fromARGB(255,255,187,85)),
                  onPressed: () {
                    addItemToOrder(context);
                  },
                ),
                const SizedBox(width: 16),
                IconButton( // Sends order request
                  onPressed: () {
                    if (orderRequests.isEmpty){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please add an item to the order.')
                        ),
                      );
                    }
                    else{
                      DBs().addOrder(
                        Orders(
                          id: "",
                          table: tableNumber,
                          requests: orderRequests,
                          status: 'Requested',
                          time: Timestamp.now(),
                          notificationStatus: "default"
                        ),
                      );
                      setState(() {
                        orderRequests = [];
                      });
                  }
                  },
                  icon: const Icon(Icons.arrow_circle_right, size: 35, color: Color.fromARGB(255,255,187,85)),
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
          backgroundColor: const Color.fromARGB(255, 125, 164, 129),
          title: const Text('Item Options',  style: TextStyle(color: Colors.black)),
          content: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: [
              ElevatedButton( // Update the item
                onPressed: () {
                  Navigator.pop(context);
                  updateItem(context, index);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(30, 28),
                  backgroundColor: const Color.fromARGB(255,255,187,85),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)
                  ),
                ),
                child: const Text('Update', style: TextStyle(color: Colors.black)),
              ),
              IconButton( // Remove the item
                onPressed: () {
                  setState(() {
                    orderRequests.removeAt(index);
                  });
                  Navigator.pop(context);
                },
                alignment: AlignmentDirectional.bottomEnd,
                icon: const Icon(Icons.delete, size: 35, color: Color.fromARGB(255,255,187,85)),
              ),
              IconButton( // Cancel
                onPressed: () {
                  Navigator.pop(context);
                },
                alignment: AlignmentDirectional.bottomEnd,
                icon: const Icon(Icons.cancel, size: 35, color: Color.fromARGB(255,255,187,85)),
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
              icon: const Icon(Icons.check_circle, size: 35, color: Color.fromARGB(255,255,187,85)),
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
                      child:  ListTile(
                      title: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${String.fromCharCode(0x2022)} Table: ${orders[index].table}'),
                            Text('   Status: ${orders[index].status}', style: const TextStyle(color: Colors.black, fontSize: 13.0))
                          ])
                        ),
                      )
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
          backgroundColor: const Color.fromARGB(255, 125, 164, 129),
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
              cursorColor: const Color.fromARGB(255,255,187,85)
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
              ),
              cursorColor: const Color.fromARGB(255,255,187,85)
            ),
            const SizedBox(height: 15.0),
            IconButton( // Adds the item to the request
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
              alignment: Alignment.bottomRight,
              icon: const Icon(Icons.add_circle_rounded, size: 35, color: Color.fromARGB(255,255,187,85)),
            ),
          ],
        ),
      );
    },
  );
  }
}
