class Orders {
  String table;
  List<Request> requests;
  String status;

  Orders({required this.table,required this.requests,required this.status});

  
  factory Orders.fromJson(Map<String, dynamic> json) {
    return Orders(
      table: json['table'],
      requests: (json['requests'] as List<dynamic>).map((requestData) {
        return Request(
          item: requestData['itemCode'],
          notes: requestData['notes'],
          quantity: requestData['quantity'],
        );
      }).toList(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'table': table,
      'requests': requests.map((request) => {
        'itemCode': request.item,
        'notes': request.notes,
        'quantity': request.quantity,
      }).toList(),
      'status': status,
    };
  }
}

class Request {
  String item;
  String notes;
  int quantity;

  Request({
    required this.item,
    required this.notes,
    required this.quantity,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      item: json['item'],
      notes: json['notes'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'notes': notes,
      'quantity': quantity,
    };
  }
}


class Item {
  String code;
  String description;
  int price;

  Item({required this.code,required this.description,required this.price});

   Map<String,dynamic> toJson(){
    return {
      'code' : code,
      'description': description,
      'price': price,
    };
  }

  factory Item.fromJson(Map<String,dynamic> json){
    return Item(
      code: json['code'],
      description: json['description'],
      price: json['price'],
    );
  }

  @override
  bool operator ==(Object other) {
    return (other is Item &&
      other.code == code &&
      other.description == description &&
      other.price == price);
  }

  @override
  int get hashCode => code.hashCode;
}
