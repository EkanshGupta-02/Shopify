import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime datetime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.datetime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  final String authtoken;
  final String userId;

  Orders(this.authtoken,this.userId,this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchandSetOrders() async {
    final url = Uri.parse(
        'https://flutter-app-5c66d-default-rtdb.firebaseio.com/Orders/$userId.json?auth=$authtoken');
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if(extractedData == null){
      return;
    }
    extractedData.forEach((orderid, orderdata) {
      loadedOrders.add(OrderItem(
        id: orderid,
        amount: orderdata['amount'],
        datetime: DateTime.parse(orderdata['datetime']),
        products: (orderdata['products'] as List<dynamic>)
            .map(
              (item) => CartItem(
                id: item['id'],
                title: item['title'],
                quantity: item['quantity'],
                price: item['price'],
              ),
            )
            .toList(),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addorders(List<CartItem> cartproducts, double amount) async {
    final url = Uri.parse(
        'https://flutter-app-5c66d-default-rtdb.firebaseio.com/Orders/$userId.json?auth=$authtoken');
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': double.parse(amount.toStringAsFixed(2)),
          'datetime': timestamp.toIso8601String(),
          'products': cartproducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }));
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: amount,
        products: cartproducts,
        datetime: timestamp,
      ),
    );
    notifyListeners();
  }
}
