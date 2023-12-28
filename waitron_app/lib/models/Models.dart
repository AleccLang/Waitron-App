import 'package:cloud_firestore/cloud_firestore.dart';

// Represents an order
class Orders {
  String id;
  String table;
  List<Request> requests;
  String status;
  String notificationStatus;
  Timestamp time;

  // Constructor for Orders class
  Orders({required this.id, required this.table,required this.requests,required this.status, required this.time, required this.notificationStatus});

  // Creates an Orders object from JSON data
  factory Orders.fromJson(Map<String, dynamic> json) {
    return Orders(
      id: json['id'],
      table: json['table'],
      requests: (json['requests'] as List<dynamic>).map((requestData) {
        return Request(
          item: requestData['itemCode'],
          notes: requestData['notes'],
          quantity: requestData['quantity'],
        );
      }).toList(),
      status: json['status'],
      time: json['time'],
      notificationStatus: json['notificationStatus']
    );
  }

  // Converts an Orders object to a JSON representation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table': table,
      'requests': requests.map((request) => {
        'itemCode': request.item,
        'notes': request.notes,
        'quantity': request.quantity,
      }).toList(),
      'status': status,
      'time': time,
      'notificationStatus': notificationStatus
    };
  }
}

// Represents a request within an order
class Request {
  String item;
  String notes;
  int quantity;

  // Constructor for Request class
  Request({required this.item, required this.notes,required this.quantity});

  // Creates a Request from JSON data
  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      item: json['item'],
      notes: json['notes'],
      quantity: json['quantity'],
    );
  }

  // Converts a Request to a JSON representation
  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'notes': notes,
      'quantity': quantity,
    };
  }
}

// Represents an item in the menu
class Item {
  String code;
  String description;
  int price;

  // Constructor for the Item class
  Item({required this.code,required this.description,required this.price});

  // Converts the Item object to a JSON representation
   Map<String,dynamic> toJson(){
    return {
      'code' : code,
      'description': description,
      'price': price,
    };
  }

  // Creates an Item object from JSON data
  factory Item.fromJson(Map<String,dynamic> json){
    return Item(
      code: json['code'],
      description: json['description'],
      price: json['price'],
    );
  }

  // Override equality operator to compare Item objects
  @override
  bool operator ==(Object other) {
    return (other is Item &&
      other.code == code &&
      other.description == description &&
      other.price == price);
  }
  
  // Override hashCode for equality comparisons
  @override
  int get hashCode => code.hashCode;
}

// Represents a Table, used to keep track of which tables are currently in use
class Tables {
  String tableNumber;

  // Constructor for Table class
  Tables({required this.tableNumber});

  // Creates a Table from JSON data
  factory Tables.fromJson(Map<String, dynamic> json) {
    return Tables(
      tableNumber: json['tableNumber'],
    );
  }

  // Converts a Table to a JSON representation
  Map<String, dynamic> toJson() {
    return {
      'tableNumber': tableNumber,
    };
  }
}
