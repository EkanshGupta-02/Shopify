import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';
import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';

class UserProductScreen extends StatelessWidget {
  
  static const routename = '/user-product';

  const UserProductScreen({Key key}) : super(key: key); 

  Future<void> _resfresfProducts(BuildContext context) async{
    await  Provider.of<Products>(context,listen: false).fetchandSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // print('Rebuild');
    // final productData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routename);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: _resfresfProducts(context),
        builder: (ctx,snapshot) => snapshot.connectionState == ConnectionState.waiting ?
        const Center(child: const CircularProgressIndicator(),) :RefreshIndicator(
          onRefresh: () => _resfresfProducts(context),
          child: Consumer<Products>(
            builder: (ctx, productData, _) =>  Padding(
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              itemCount: productData.items.length,
              itemBuilder: (_, i) => Column(
                children: [
                  UserProductItem(
                    productData.items[i].id,
                    productData.items[i].title,
                    productData.items[i].imageurl,
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}
