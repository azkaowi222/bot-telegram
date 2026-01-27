import 'package:admin_telegram_bot/controllers/product_controller.dart';
import 'package:admin_telegram_bot/models/account_stock.dart';
import 'package:flutter/material.dart';
import '../controllers/account_stock_controller.dart';

class StocksPage extends StatefulWidget {
  const StocksPage({super.key});

  @override
  State<StocksPage> createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.addListener(_onUpdate);
    productController.addListener(_onUpdate);
    controller.getAllAccountsStocks();
    productController.getAllProducts();
  }

  void _onUpdate() {
    setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_onUpdate);
    controller.dispose();
    productController.removeListener(_onUpdate);
    productController.dispose();
    super.dispose();
  }

  final AccountStockController controller = AccountStockController();
  final ProductController productController = ProductController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController metadataController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final List<String> status = ['available', 'reserved', 'sold'];
  String? statusValue;
  String? dropdownValue;
  String? emailForFind;
  double keyboarHeight = 0;

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final List<String> allCategories =
        productController.products.map((e) {
          return e.category;
        }).toList();
    final List<Map<String, dynamic>> stocks = [];
    final categories = Set.from(allCategories).toList();
    for (int i = 0; i < categories.length; i++) {
      stocks.add({
        categories[i]:
            controller.accountStocks.where((AccountStock e) {
              return e.category == categories[i];
            }).toList(),
      });
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Accounts stocks',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 30),
        Expanded(
          child:
              controller.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    itemCount: productController.products.length,
                    itemBuilder: (context, index) {
                      final account = productController.products[index];
                      final stockKey = stocks[index].keys.single;
                      final List<AccountStock> stockValue =
                          stocks[index][stockKey];
                      return Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: 1.5,
                            color: Colors.black.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(account.name),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  dropdownValue = null;
                                                  keyboarHeight = 0;
                                                  _formKey.currentState
                                                      ?.reset();
                                                  emailController.clear();
                                                  passwordController.clear();
                                                  metadataController.clear();
                                                  statusValue = null;
                                                  showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    context: context,
                                                    builder: (context) {
                                                      return StatefulBuilder(
                                                        builder: (
                                                          context,
                                                          setBottomState,
                                                        ) {
                                                          return Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                  left: 20,
                                                                  right: 20,
                                                                  top: 12,
                                                                  bottom:
                                                                      keyboarHeight +
                                                                      50,
                                                                ),
                                                            width:
                                                                double.infinity,
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () => Navigator.pop(
                                                                            context,
                                                                          ),
                                                                      child: Icon(
                                                                        Icons
                                                                            .arrow_back_rounded,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Container(
                                                                      margin:
                                                                          EdgeInsets.only(
                                                                            top:
                                                                                3,
                                                                          ),
                                                                      child: Text(
                                                                        'Edit stock',
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: Align(
                                                                        alignment:
                                                                            Alignment.centerRight,
                                                                        child: GestureDetector(
                                                                          onTap: () async {
                                                                            if (_formKey.currentState!.validate()) {
                                                                              final AccountStock
                                                                              editedProduct = controller.accountStocks.firstWhere(
                                                                                (
                                                                                  AccountStock account,
                                                                                ) {
                                                                                  return account.email ==
                                                                                      emailForFind;
                                                                                },
                                                                              );
                                                                              print(
                                                                                'statusController: ${statusController.text}',
                                                                              );
                                                                              final AccountStock
                                                                              newAccount = AccountStock(
                                                                                id:
                                                                                    editedProduct.id,
                                                                                product: {
                                                                                  'id':
                                                                                      account.id,
                                                                                },
                                                                                email:
                                                                                    emailController.text,
                                                                                password:
                                                                                    passwordController.text,
                                                                                status:
                                                                                    statusController.text,
                                                                                createdAt:
                                                                                    DateTime.now().toString(),
                                                                                category:
                                                                                    account.category,
                                                                                metadata: {
                                                                                  '2fa':
                                                                                      metadataController.text,
                                                                                },
                                                                              );

                                                                              final int?
                                                                              statusCode = await controller.updateAccountStock(
                                                                                newAccount,
                                                                              );

                                                                              if (context.mounted) {
                                                                                Navigator.pop(
                                                                                  context,
                                                                                );
                                                                                ScaffoldMessenger.of(
                                                                                  context,
                                                                                ).showSnackBar(
                                                                                  SnackBar(
                                                                                    content: Text(
                                                                                      statusCode ==
                                                                                              200
                                                                                          ? 'Stock Edited succesfully'
                                                                                          : 'Failed add stcok',
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              }
                                                                            }
                                                                          },
                                                                          child: Container(
                                                                            padding: EdgeInsets.all(
                                                                              8,
                                                                            ),
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(
                                                                                8,
                                                                              ),
                                                                              color:
                                                                                  Colors.blue.shade300,
                                                                            ),
                                                                            margin: EdgeInsets.only(
                                                                              top:
                                                                                  2,
                                                                            ),
                                                                            child: Text(
                                                                              'Save',
                                                                              style: TextStyle(
                                                                                fontSize:
                                                                                    14,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 30,
                                                                ),
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          4,
                                                                        ),
                                                                    border: Border.all(
                                                                      width: 1,
                                                                      color: Colors
                                                                          .black
                                                                          .withValues(
                                                                            alpha:
                                                                                0.5,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  child: DropdownButton<
                                                                    String
                                                                  >(
                                                                    hint: Text(
                                                                      'Select account',
                                                                    ),
                                                                    value:
                                                                        dropdownValue,
                                                                    padding:
                                                                        EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              8,
                                                                        ),
                                                                    isExpanded:
                                                                        true,
                                                                    underline:
                                                                        SizedBox(),

                                                                    items: [
                                                                      ...stockValue.map((
                                                                        AccountStock
                                                                        account,
                                                                      ) {
                                                                        return DropdownMenuItem(
                                                                          value:
                                                                              account.email,
                                                                          child: Text(
                                                                            account.email,
                                                                          ),
                                                                        );
                                                                      }),
                                                                    ],

                                                                    onChanged: (
                                                                      value,
                                                                    ) {
                                                                      final indexEmail = stockValue.indexWhere((
                                                                        AccountStock
                                                                        account,
                                                                      ) {
                                                                        return account.email ==
                                                                            value;
                                                                      });
                                                                      emailForFind =
                                                                          value;
                                                                      if (indexEmail !=
                                                                          -1) {
                                                                        setBottomState(() {
                                                                          dropdownValue =
                                                                              value;
                                                                          print(
                                                                            stockValue[indexEmail].status,
                                                                          );

                                                                          emailController.text =
                                                                              stockValue[indexEmail].email;
                                                                          passwordController.text =
                                                                              stockValue[indexEmail].password;
                                                                          metadataController.text =
                                                                              stockValue[indexEmail].metadata['2fa'];
                                                                          statusController.text =
                                                                              stockValue[indexEmail].status;
                                                                          statusValue =
                                                                              stockValue[indexEmail].status;
                                                                        });
                                                                      }
                                                                    },
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 30,
                                                                ),

                                                                Form(
                                                                  key: _formKey,
                                                                  child: Column(
                                                                    children: [
                                                                      TextFormField(
                                                                        onTap: () {
                                                                          setBottomState(
                                                                            () =>
                                                                                keyboarHeight =
                                                                                    220,
                                                                          );
                                                                        },
                                                                        onFieldSubmitted: (
                                                                          value,
                                                                        ) {
                                                                          setBottomState(
                                                                            () =>
                                                                                keyboarHeight =
                                                                                    0,
                                                                          );
                                                                        },
                                                                        controller:
                                                                            emailController,
                                                                        autovalidateMode:
                                                                            AutovalidateMode.onUserInteraction,
                                                                        validator: (
                                                                          value,
                                                                        ) {
                                                                          if (value!
                                                                              .isEmpty) {
                                                                            return 'Field required';
                                                                          }
                                                                          return null;
                                                                        },

                                                                        decoration: InputDecoration(
                                                                          contentPadding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                8,
                                                                          ),
                                                                          border:
                                                                              OutlineInputBorder(),
                                                                          labelText:
                                                                              'Username/email',
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            30,
                                                                      ),
                                                                      TextFormField(
                                                                        onTap: () {
                                                                          setBottomState(
                                                                            () =>
                                                                                keyboarHeight =
                                                                                    220,
                                                                          );
                                                                        },
                                                                        onFieldSubmitted: (
                                                                          value,
                                                                        ) {
                                                                          setBottomState(
                                                                            () =>
                                                                                keyboarHeight =
                                                                                    0,
                                                                          );
                                                                        },
                                                                        controller:
                                                                            passwordController,
                                                                        autovalidateMode:
                                                                            AutovalidateMode.onUserInteraction,
                                                                        validator: (
                                                                          value,
                                                                        ) {
                                                                          if (value!
                                                                              .isEmpty) {
                                                                            return 'Field required';
                                                                          }
                                                                          return null;
                                                                        },

                                                                        decoration: InputDecoration(
                                                                          contentPadding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                8,
                                                                          ),
                                                                          border:
                                                                              OutlineInputBorder(),
                                                                          labelText:
                                                                              'Password',
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            30,
                                                                      ),
                                                                      TextFormField(
                                                                        onTap: () {
                                                                          setBottomState(
                                                                            () =>
                                                                                keyboarHeight =
                                                                                    220,
                                                                          );
                                                                        },
                                                                        onFieldSubmitted: (
                                                                          value,
                                                                        ) {
                                                                          setBottomState(
                                                                            () =>
                                                                                keyboarHeight =
                                                                                    0,
                                                                          );
                                                                        },
                                                                        controller:
                                                                            metadataController,
                                                                        autovalidateMode:
                                                                            AutovalidateMode.onUserInteraction,
                                                                        validator: (
                                                                          value,
                                                                        ) {
                                                                          if (value!
                                                                              .isEmpty) {
                                                                            return 'Field required';
                                                                          }
                                                                          return null;
                                                                        },

                                                                        decoration: InputDecoration(
                                                                          contentPadding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                8,
                                                                          ),
                                                                          border:
                                                                              OutlineInputBorder(),
                                                                          labelText:
                                                                              '2fa',
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            30,
                                                                      ),
                                                                      Container(
                                                                        decoration: BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                4,
                                                                              ),
                                                                          border: Border.all(
                                                                            width:
                                                                                1,
                                                                            color: Colors.black.withValues(
                                                                              alpha:
                                                                                  0.5,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        child: DropdownButton<
                                                                          String
                                                                        >(
                                                                          hint: Text(
                                                                            'Status',
                                                                          ),
                                                                          padding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                8,
                                                                          ),
                                                                          underline:
                                                                              SizedBox(),
                                                                          isExpanded:
                                                                              true,
                                                                          value:
                                                                              statusValue,
                                                                          items: [
                                                                            ...status.map((
                                                                              e,
                                                                            ) {
                                                                              return DropdownMenuItem(
                                                                                value:
                                                                                    e,
                                                                                child: Text(
                                                                                  e,
                                                                                ),
                                                                              );
                                                                            }),
                                                                          ],
                                                                          onChanged: (
                                                                            value,
                                                                          ) {
                                                                            setBottomState(() {
                                                                              statusController.text = value!;
                                                                              statusValue =
                                                                                  value;
                                                                            });
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.edit_square,
                                                  color: Colors.blue.shade400,
                                                  semanticLabel: 'Edit stock',
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              GestureDetector(
                                                onTap: () {
                                                  keyboarHeight = 0;
                                                  _formKey.currentState
                                                      ?.reset();
                                                  emailController.clear();
                                                  passwordController.clear();
                                                  metadataController.clear();

                                                  showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    context: context,
                                                    builder: (context) {
                                                      return StatefulBuilder(
                                                        builder: (
                                                          context,
                                                          setBottomState,
                                                        ) {
                                                          return Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                  left: 20,
                                                                  right: 20,
                                                                  top: 12,
                                                                  bottom:
                                                                      keyboarHeight +
                                                                      50,
                                                                ),
                                                            width:
                                                                double.infinity,
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () => Navigator.pop(
                                                                            context,
                                                                          ),
                                                                      child: Icon(
                                                                        Icons
                                                                            .arrow_back_rounded,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Container(
                                                                      margin:
                                                                          EdgeInsets.only(
                                                                            top:
                                                                                3,
                                                                          ),
                                                                      child: Text(
                                                                        'Add stock',
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: Align(
                                                                        alignment:
                                                                            Alignment.centerRight,
                                                                        child: GestureDetector(
                                                                          onTap: () async {
                                                                            if (_formKey.currentState!.validate()) {
                                                                              final AccountStock
                                                                              newAccount = AccountStock(
                                                                                product: {
                                                                                  'id':
                                                                                      account.id,
                                                                                },
                                                                                email:
                                                                                    emailController.text,
                                                                                password:
                                                                                    passwordController.text,
                                                                                status:
                                                                                    'available',
                                                                                createdAt:
                                                                                    DateTime.now().toString(),
                                                                                category:
                                                                                    account.category,
                                                                                metadata: {
                                                                                  '2fa':
                                                                                      metadataController.text,
                                                                                },
                                                                              );
                                                                              final accountStock =
                                                                                  controller.accountStocks.length;

                                                                              await controller.addAccountStock(
                                                                                newAccount,
                                                                              );
                                                                              final accountStockAfterAdd =
                                                                                  controller.accountStocks.length;
                                                                              if (context.mounted) {
                                                                                Navigator.pop(
                                                                                  context,
                                                                                );
                                                                                ScaffoldMessenger.of(
                                                                                  context,
                                                                                ).showSnackBar(
                                                                                  SnackBar(
                                                                                    content: Text(
                                                                                      accountStock <
                                                                                              accountStockAfterAdd
                                                                                          ? 'Stock added succesfully'
                                                                                          : 'Failed add stcok',
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              }
                                                                            }
                                                                          },
                                                                          child: Container(
                                                                            padding: EdgeInsets.all(
                                                                              8,
                                                                            ),
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(
                                                                                8,
                                                                              ),
                                                                              color:
                                                                                  Colors.blue.shade300,
                                                                            ),
                                                                            margin: EdgeInsets.only(
                                                                              top:
                                                                                  2,
                                                                            ),
                                                                            child: Text(
                                                                              'Save',
                                                                              style: TextStyle(
                                                                                fontSize:
                                                                                    14,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 30,
                                                                ),
                                                                Form(
                                                                  key: _formKey,
                                                                  child: Column(
                                                                    children: [
                                                                      TextFormField(
                                                                        onTap: () {
                                                                          setBottomState(
                                                                            () =>
                                                                                keyboarHeight =
                                                                                    220,
                                                                          );
                                                                        },
                                                                        onFieldSubmitted: (
                                                                          value,
                                                                        ) {
                                                                          setBottomState(
                                                                            () =>
                                                                                keyboarHeight =
                                                                                    0,
                                                                          );
                                                                        },
                                                                        controller:
                                                                            emailController,
                                                                        autovalidateMode:
                                                                            AutovalidateMode.onUserInteraction,
                                                                        validator: (
                                                                          value,
                                                                        ) {
                                                                          if (value!
                                                                              .isEmpty) {
                                                                            return 'Field required';
                                                                          }
                                                                          return null;
                                                                        },

                                                                        decoration: InputDecoration(
                                                                          contentPadding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                8,
                                                                          ),
                                                                          border:
                                                                              OutlineInputBorder(),
                                                                          labelText:
                                                                              'Username/email',
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            30,
                                                                      ),
                                                                      TextFormField(
                                                                        onTap: () {
                                                                          setBottomState(
                                                                            () =>
                                                                                keyboarHeight =
                                                                                    220,
                                                                          );
                                                                        },
                                                                        onFieldSubmitted: (
                                                                          value,
                                                                        ) {
                                                                          setBottomState(
                                                                            () =>
                                                                                keyboarHeight =
                                                                                    0,
                                                                          );
                                                                        },
                                                                        controller:
                                                                            passwordController,
                                                                        autovalidateMode:
                                                                            AutovalidateMode.onUserInteraction,
                                                                        validator: (
                                                                          value,
                                                                        ) {
                                                                          if (value!
                                                                              .isEmpty) {
                                                                            return 'Field required';
                                                                          }
                                                                          return null;
                                                                        },

                                                                        decoration: InputDecoration(
                                                                          contentPadding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                8,
                                                                          ),
                                                                          border:
                                                                              OutlineInputBorder(),
                                                                          labelText:
                                                                              'Password',
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            30,
                                                                      ),
                                                                      TextFormField(
                                                                        onTap: () {
                                                                          setBottomState(
                                                                            () =>
                                                                                keyboarHeight =
                                                                                    220,
                                                                          );
                                                                        },
                                                                        onFieldSubmitted: (
                                                                          value,
                                                                        ) {
                                                                          setBottomState(
                                                                            () =>
                                                                                keyboarHeight =
                                                                                    0,
                                                                          );
                                                                        },
                                                                        controller:
                                                                            metadataController,
                                                                        autovalidateMode:
                                                                            AutovalidateMode.onUserInteraction,
                                                                        validator: (
                                                                          value,
                                                                        ) {
                                                                          if (value!
                                                                              .isEmpty) {
                                                                            return 'Field required';
                                                                          }
                                                                          return null;
                                                                        },

                                                                        decoration: InputDecoration(
                                                                          contentPadding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                8,
                                                                          ),
                                                                          border:
                                                                              OutlineInputBorder(),
                                                                          labelText:
                                                                              '2fa',
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.add_circle,
                                                  color: Colors.blue.shade400,
                                                  semanticLabel: 'Add stock',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      ...stockValue.map((AccountStock e) {
                                        return Container(
                                          // width: 100,
                                          margin: EdgeInsets.only(bottom: 15),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                width: 1.2,
                                                color: Colors.black.withValues(
                                                  alpha: 0.2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: deviceWidth * 0.7,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Username/email: ${e.email}',
                                                          softWrap: true,
                                                        ),
                                                        Text(
                                                          'Password: ${e.password}',
                                                        ),
                                                        Text(
                                                          '2fa: ${e.metadata['2fa']}',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    e.status,
                                                    style: TextStyle(
                                                      color:
                                                          e.status ==
                                                                  'available'
                                                              ? Colors
                                                                  .green
                                                                  .shade300
                                                              : e.status ==
                                                                  'reserved'
                                                              ? Colors.orange
                                                              : Colors
                                                                  .red
                                                                  .shade400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
