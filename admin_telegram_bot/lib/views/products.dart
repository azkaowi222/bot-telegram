import 'package:admin_telegram_bot/controllers/orders_history_controller.dart';
import 'package:admin_telegram_bot/controllers/product_controller.dart';
import 'package:admin_telegram_bot/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Products extends StatefulWidget {
  final ProductController controller;
  const Products({super.key, required this.controller});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.controller.addListener(_onUpdate);
    widget.controller.getAllProducts();
  }

  void _onUpdate() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    // widget.controller.dispose();
    super.dispose();
  }

  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print('page products dipanggil');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            IconButton(
              onPressed: () {
                messageController.clear();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Align(
                        alignment: Alignment.center,
                        child: Text('Broadcast'),
                      ),
                      titlePadding: EdgeInsets.all(8),
                      shape: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      contentPadding: EdgeInsets.all(8),
                      content: Container(
                        margin: EdgeInsets.only(top: 30),
                        child: TextField(
                          controller: messageController,
                          minLines: 4,
                          maxLines: null,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () async {
                                final message = await widget.controller
                                    .sendBroadcast(messageController.text);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                              icon: Icon(Icons.send_rounded),
                            ),
                            labelText: 'Message',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              constraints: const BoxConstraints(),
              style: const ButtonStyle(
                tapTargetSize:
                    MaterialTapTargetSize
                        .shrinkWrap, // 3. Kecilkan area sentuh agar pas body
              ),
              icon: Icon(Icons.send_rounded),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        SizedBox(height: 30),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.5),
                      spreadRadius: 1.4,
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: TextField(
                  autofocus: false,
                  // focusNode: _focusNode,
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  onChanged: (value) {
                    widget.controller.handleSearch(value);
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    // isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    hintText: '🔍 Search',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 18, right: 5),
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                // border: Border.all(width: 2),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
                    blurRadius: 1,
                    spreadRadius: 1,
                    // offset: Offset(3, 3),
                  ),
                ],
              ),
              child: SizedBox(
                width: 42,
                height: 42,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,

                  // constraints: const BoxConstraints(),
                  icon: const Icon(Icons.filter_alt_outlined),
                  onSelected: (value) {
                    // handle filter
                    print(value);
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'data',
                          child: Container(
                            decoration: BoxDecoration(color: Colors.amber),
                            child: Text('Data'),
                          ),
                        ),
                      ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        widget.controller.isLoading
            ? Expanded(child: Center(child: CircularProgressIndicator()))
            : Expanded(
              child: ListView.builder(
                itemCount: widget.controller.products.length,
                itemBuilder: (context, index) {
                  final product = widget.controller.products[index];

                  return Container(
                    // color: Colors.green,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: Colors.black.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 215, 252, 211),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 15),
                                SizedBox(width: 5),
                                Text(
                                  product.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(product.name, style: TextStyle(fontSize: 14.5)),
                        ],
                      ),
                      subtitle: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Rp. ${product.price.toString()}K',
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.circle, size: 5, color: Colors.grey),
                          SizedBox(width: 10),
                          Text(
                            '${product.stock ?? '0'} stocks',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap:
                                () => {
                                  bottomBar(
                                    context,
                                    widget.controller,
                                    product,
                                  ),
                                  FocusScope.of(context).unfocus(),
                                },

                            child: Icon(Icons.edit_square, size: 20),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return AlertDialog(
                                    shape: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    actions: [
                                      GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: Container(
                                          padding: EdgeInsets.all(8),

                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8),
                                            ),
                                            color: Colors.black.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.black.withValues(
                                                alpha: 0.6,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final totalProducts =
                                              widget.controller.products.length;
                                          await widget.controller.deleteProduct(
                                            name: product.name,
                                          );
                                          final totalProductsAfterDelete =
                                              widget.controller.products.length;
                                          // setState(() {});
                                          if (context.mounted) {
                                            Navigator.pop(context);

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  totalProductsAfterDelete <
                                                          totalProducts
                                                      ? 'Delete successfull'
                                                      : 'Failed to Delete',
                                                ),
                                                duration: Duration(seconds: 3),
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),

                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8),
                                            ),
                                            color: Colors.red.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: Colors.black.withValues(
                                                alpha: 0.6,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    content: Text(
                                      '${product.name} will be delete permanently, you sure?',
                                    ),
                                  );
                                },
                              );
                            },

                            child: Icon(Icons.delete_forever_rounded, size: 20),
                          ),
                        ],
                      ),
                      leading: AspectRatio(
                        aspectRatio: 1 / 1,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Color(0xFFDBDBD5).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.network(
                            '$backendUrl/${product.imgPath}',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      ],
    );
  }
}

void bottomBar(
  BuildContext context,
  ProductController controller,
  ProductModel product,
) {
  int keyboarHeight = 0;
  print(keyboarHeight);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final productNameController = TextEditingController(text: product.name);
  final priceController = TextEditingController(text: product.price.toString());
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setBottomState) {
          return Container(
            // height: kToolbarHeight,
            width: double.infinity,
            padding: EdgeInsets.only(
              top: 20,
              bottom: keyboarHeight + 75,
              left: 18,
              right: 18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        // border: Border.all(width: 2),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.keyboard_arrow_left_rounded),
                          ),
                          SizedBox(width: 5),
                          Container(
                            margin: EdgeInsets.only(top: 2),
                            child: Text('Edit product'),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          final ProductModel editedUser = ProductModel(
                            id: product.id,
                            name: productNameController.text,
                            balance: product.balance,
                            price:
                                num.tryParse(priceController.text) ??
                                product.price,
                            category: product.category,
                            isActive: true,
                            imgPath: product.imgPath,
                          );
                          final int statusCode = await controller.editProduct(
                            editedUser,
                          );
                          print(statusCode);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  statusCode != 200
                                      ? 'Failed update..'
                                      : 'Update successfull',
                                ),
                              ),
                            );
                          }
                        }
                      },

                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.black.withValues(alpha: 0.2),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Text('Save'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          onTapOutside: (_) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            setBottomState(() => keyboarHeight = 0);
                          },
                          onFieldSubmitted: (_) {
                            setBottomState(() => keyboarHeight = 0);
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            border: OutlineInputBorder(),
                            labelText: 'Product name',
                          ),
                          onTap: () {
                            setBottomState(() => keyboarHeight = 200);
                          },
                          controller: productNameController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Field required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          onTapOutside: (_) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            setBottomState(() => keyboarHeight = 0);
                          },
                          onFieldSubmitted: (_) {
                            setBottomState(() => keyboarHeight = 0);
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            labelText: 'Price',
                          ),
                          onTap: () {
                            setBottomState(() => keyboarHeight = 200);
                          },
                          controller: priceController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Field required';
                            }
                            if (num.parse(value) < 1) {
                              return 'Must be grater then zero';
                            }
                            if (value[0] == '0') {
                              return 'First character not allowed';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
