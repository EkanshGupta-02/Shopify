import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key key}) : super(key: key);

  static const routename = '/edit-product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _pricefocusnode = FocusNode();
  final _descriptionfocusnode = FocusNode();
  final _imagetextController = TextEditingController();
  final _imagefocusnode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedproduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageurl: '',
  );

  var _initValues = {
    'title': ' ',
    'price': ' ',
    'description': '',
    'imageurl': '',
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imagefocusnode.addListener(_updateUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productid = ModalRoute.of(context).settings.arguments as String;
      if (productid != null) {
        _editedproduct =
            Provider.of<Products>(context, listen: false).findById(productid);
        _initValues = {
          'title': _editedproduct.title,
          'price': _editedproduct.price.toString(),
          'description': _editedproduct.description,
          'imageurl': '',
        };
        _imagetextController.text = _editedproduct.imageurl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imagefocusnode.removeListener(_updateUrl);
    _pricefocusnode.dispose();
    _descriptionfocusnode.dispose();
    _imagetextController.dispose();
    _imagefocusnode.dispose();
    super.dispose();
  }

  void _updateUrl() {
    if (_imagetextController.text.isEmpty ||
        (!_imagetextController.text.startsWith('http') &&
            !_imagetextController.text.startsWith('https')) ||
        (!_imagetextController.text.endsWith('.jpg') &&
            !_imagetextController.text.endsWith('.jpeg') &&
            !_imagetextController.text.endsWith('.png'))) {
      return;
    }

    if (!_imagefocusnode.hasFocus) {
      setState(() {});
    }
  }

 Future<void> _saveform() async{
    final validinput = _form.currentState.validate();
    if (!validinput) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedproduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateproduct(_editedproduct.id, _editedproduct);
    } else {
      try{
      await Provider.of<Products>(context, listen: false)
          .addProduct(_editedproduct);
      }
      catch(error){
          await showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                            title: const Text('There is some Error!'),
                            content: const Text('Something Went Wrong!'),
                            actions: [
                              TextButton(onPressed: (){
                                Navigator.of(context).pop();
                              }, child: const Text("Exit"))
                            ],
                          ));
        }
        // finally{
        //   setState(() {
        //       _isLoading = false;
        //     });
        //     Navigator.of(context).pop();
        // }
    }
     setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: (_saveform),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: const InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_pricefocusnode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Enter a Value';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedproduct = Product(
                          id: _editedproduct.id,
                          title: value,
                          description: _editedproduct.description,
                          price: _editedproduct.price,
                          imageurl: _editedproduct.imageurl,
                          isfavorite: _editedproduct.isfavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: const InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _pricefocusnode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionfocusnode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter the Price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a Valid Price';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Enter a Valid Price';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedproduct = Product(
                          id: _editedproduct.id,
                          title: _editedproduct.title,
                          description: _editedproduct.description,
                          price: double.parse(value),
                          imageurl: _editedproduct.imageurl,
                          isfavorite: _editedproduct.isfavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionfocusnode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter the Description';
                        }
                        if (value.length <= 10) {
                          return 'Enter a bigger description';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedproduct = Product(
                          id: _editedproduct.id,
                          title: _editedproduct.title,
                          description: value,
                          price: _editedproduct.price,
                          imageurl: _editedproduct.imageurl,
                          isfavorite: _editedproduct.isfavorite,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          margin: const EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imagetextController.text.isEmpty
                              ? const Text('Enter a URl')
                              : FittedBox(
                                  fit: BoxFit.cover,
                                  child:
                                      Image.network(_imagetextController.text),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Image Url'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imagetextController,
                            focusNode: _imagefocusnode,
                            onFieldSubmitted: (_) {
                              _saveform();
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter a URL';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Enter a Valid URL';
                              }
                              if (!value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg') &&
                                  !value.endsWith('.png')) {
                                return 'Enter a Valid URL';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedproduct = Product(
                                id: _editedproduct.id,
                                title: _editedproduct.title,
                                description: _editedproduct.description,
                                price: _editedproduct.price,
                                imageurl: value,
                                isfavorite: _editedproduct.isfavorite,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
