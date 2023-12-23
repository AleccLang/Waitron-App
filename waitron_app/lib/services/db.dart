import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waitron_app/models/Models.dart';

class DBs {

  // Collection references
  final CollectionReference orderCollection = FirebaseFirestore.instance.collection('orders');
  final CollectionReference itemCollection = FirebaseFirestore.instance.collection('items');


  // Orders snapshot and CRUD methods

  


  // Items CRUD methods:

  // Stream<List<Item>> getStream() {
  //   return orderCollection.snapshots().map((snapshot) => snapshot.docs.map((document) => Item.fromJson(document.data())).toList());
  // }

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