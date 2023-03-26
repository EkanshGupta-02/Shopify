import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routename = '/cart';

  const CartScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(children: [
        Card(
          margin: const EdgeInsets.all(15.0),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Chip(
                  label: Text(
                    '\$${cart.totalamount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryTextTheme.headline6.color,
                    ),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                OrderButton(cart: cart),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
            child: ListView.builder(
          itemCount: cart.itemcount,
          itemBuilder: (context, index) => CartItem(
            id: cart.items.values.toList()[index].id,
            productid: cart.items.keys.toList()[index],
            title: cart.items.values.toList()[index].title,
            quantity: cart.items.values.toList()[index].quantity,
            price: cart.items.values.toList()[index].price,
          ),
        ))
      ]),
    );
  }
}

class OrderButton extends StatefulWidget{
  const OrderButton({Key key,@required this.cart,}):super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isloading = false;
  @override 
  Widget build(BuildContext context){
    return TextButton(
                  onPressed: (widget.cart.totalamount <=0 || _isloading) ? null : () async {
                    setState(() {
                      _isloading = true;
                    });
                    await Provider.of<Orders>(context, listen: false).addorders(
                      widget.cart.items.values.toList(),
                      widget.cart.totalamount,
                    );
                    setState(() {
                      _isloading = false;
                    });
                    widget.cart.clear();
                  },
                  style: TextButton.styleFrom(
                    primary: Theme.of(context).colorScheme.primary,
                  ),
                  child: _isloading? const Center(child: CircularProgressIndicator()) :  const Text('PLACE ORDER'),
                );
  }
}
