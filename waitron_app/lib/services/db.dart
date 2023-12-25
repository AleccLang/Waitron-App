import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waitron_app/models/Models.dart';

class DBs {

  // Collection references
  final CollectionReference orderCollection = FirebaseFirestore.instance.collection('orders');
  final CollectionReference itemCollection = FirebaseFirestore.instance.collection('items');


  // Orders snapshot and CRUD methods

  // Create order.
  Future addOrder(Orders order) async {
    await orderCollection.doc(order.table).set(order.toJson());
  }

  // Update order status
  void updateOrderStatus(String table, String status) async{
    orderCollection.doc(table).update({'status' : status});
  }

  // Read orders
  Stream<QuerySnapshot> getOrderStream() {
    return orderCollection.orderBy('time', descending: false).snapshots();
  }
  
  // Delete order
  void deleteOrder(Orders order) {
    orderCollection.doc(order.table).delete();
  }

  // Items CRUD methods:

  // Create item.
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

}