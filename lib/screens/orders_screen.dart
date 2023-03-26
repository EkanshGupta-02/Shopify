import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routename = '/orders';

  const OrdersScreen({Key key}) : super(key: key);

//   const OrdersScreen({Key key}) : super(key: key);

//   @override
//   State<OrdersScreen> createState() => _OrdersScreenState();
// }

// class _OrdersScreenState extends State<OrdersScreen> {

  // var _isloading = false;

  // @override
  // void initState()  {

  //   setState(() {
  //     _isloading = true;
  //   });
  //   Future.delayed(Duration.zero).then((_) async{
  //     await Provider.of<Orders>(context,listen: false).fetchandSetOrders();
  //   });
  //    setState(() {
  //     _isloading = false;
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // final ordersData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Orders'),
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(future: Provider.of<Orders>(context,listen: false).fetchandSetOrders(),
        builder: (ctx,datasnapshot){
          if(datasnapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator());
          }
          else{
            if(datasnapshot.error != null){
              return const Center(child: Text("An Error Occured."),);
            }
            else{
              return Consumer<Orders>(builder: (context, ordersData, child) => ListView.builder(
               itemCount: ordersData.orders.length,
                 itemBuilder: (ctx, i) => OrderItem(ordersData.orders[i]),
              ),
            );
            }
          }
        }
        )
      );  
  }
}
