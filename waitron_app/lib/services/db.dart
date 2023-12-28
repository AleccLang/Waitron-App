import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waitron_app/models/Models.dart';

// Class containing methods for interacting with Firestore collections
class DBs {

  // Collection references
  final CollectionReference orderCollection = FirebaseFirestore.instance.collection('orders');
  final CollectionReference itemCollection = FirebaseFirestore.instance.collection('items');
  final CollectionReference tableCollection = FirebaseFirestore.instance.collection('active_tables');

  // Orders CRUD methods:

  // Create an order
  Future addOrder(Orders order) async {
    order.id = orderCollection.doc().id;
    await orderCollection.doc(order.id).set(order.toJson());
  }

  // Update order request
  void updateOrderRequest(Orders order, List<Request> requests) async{
    orderCollection.doc(order.id).update({'requests' : order.requests});
  }

  // Update order status
  void updateOrderStatus(String id, String status) async{
    orderCollection.doc(id).update({'status' : status});
  }

  // Update an order's notification status
  void updateNotificationStatus(String id, String notificationStatus) async{
    orderCollection.doc(id).update({'notificationStatus' : notificationStatus});
  }

  // Get all orders, ordered by the time they were placed
  Stream<QuerySnapshot> getOrderStream() {
    return orderCollection.orderBy('time', descending: false).snapshots();
  }
  
  // Deletes an order
  void deleteOrder(Orders order) {
    orderCollection.doc(order.id).delete();
  }

  // Real-time listener for changes in the orders collection, called whenever there is an update to orders
  void listenToOrders(void Function(List<Orders>) ords) {
    orderCollection.snapshots().listen((QuerySnapshot<Object?> snapshot) {
      List<Orders> orders = snapshot.docs
          .map((doc) => Orders.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      ords(orders);
    });
  }

  // Items CRUD methods:

  // Creates an item
  Future addItem(Item item) async {
    await itemCollection.doc(item.code).set(item.toJson());
  }

  // Update item price
  void updatePrice(String code, int price) async{
    itemCollection.doc(code).update({'price' : price});
  }

  // Read items
  Stream<QuerySnapshot> getItemStream() {
    return itemCollection.snapshots();
  }
  
  // Delete item
  void deleteItem(Item item) {
    itemCollection.doc(item.code).delete();
  }

  // Tables CRUD methods:

  // Creates an active Table
  Future addActiveTable(Tables table) async {
    await tableCollection.doc(table.tableNumber).set(table.toJson());
  }

  // Checks if a table is active
  Future<bool> isTableActive(Tables table) async {
    QuerySnapshot querySnapshot = await tableCollection.get();
    List<Tables> tables = querySnapshot.docs
        .map((doc) => Tables.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    return tables.any((existingTable) => existingTable.tableNumber == table.tableNumber);
  }
  
  // Deletes active table
  void deleteActiveTable(Tables table) {
    tableCollection.doc(table.tableNumber).delete();
  }

}