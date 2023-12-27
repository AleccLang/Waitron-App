import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waitron_app/models/Models.dart';

class DBs {

  // Collection references
  final CollectionReference orderCollection = FirebaseFirestore.instance.collection('orders');
  final CollectionReference itemCollection = FirebaseFirestore.instance.collection('items');

  // Orders snapshot and CRUD methods

  // Create order.
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

  // Get all orders, ordered by the time they were placed
  Stream<QuerySnapshot> getOrderStream() {
    return orderCollection.orderBy('time', descending: false).snapshots();
  }
  
  // Delete an order
  void deleteOrder(Orders order) {
    orderCollection.doc(order.id).delete();
  }

  // Items CRUD methods:

  // Create an item.
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