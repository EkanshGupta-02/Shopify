import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/badge.dart';
import '../widgets/app_drawer.dart';
import './cart_screen.dart';
import '../providers/products.dart';
import '../providers/cart.dart';
import '../widgets/products_gird.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _onlyshowfavorite = false;
  var _isInit = true;
  var _isLoading = false;



  @override
  void initState() {
    // Provider.of<Products>(context).fetchandSetProducts(); Wont work

      //  Not Recommended
    // Future.delayed(Duration.zero).then((_){
    //   Provider.of<Products>(context).fetchandSetProducts();
    // });


    super.initState();
  }

  @override
  void didChangeDependencies() {
    
    if(_isInit){
      setState(() {  
         _isLoading = true;
      });
      Provider.of<Products>(context).fetchandSetProducts().then((_){
        _isLoading = false;
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final productcontainer = Provider.of<Products>(context);
    var scaffold = Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedval) {
              setState(() {
                if (selectedval == FilterOptions.favorites) {
                  _onlyshowfavorite = true;
                } else {
                  _onlyshowfavorite = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: FilterOptions.favorites,
                child: Text("favorites"),
              ),
              const PopupMenuItem(
                value: FilterOptions.all,
                child: Text("all"),
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cartData,ch) => Badge(
              value: cartData.itemcount.toString(),
              child: ch,
            ),
            child:  IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: (){
                  Navigator.of(context).pushNamed(CartScreen.routename);
                },
              ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body:_isLoading ? const Center(child: CircularProgressIndicator(),) : ProductsGrid(_onlyshowfavorite),
    );
    return scaffold;
  }
}
