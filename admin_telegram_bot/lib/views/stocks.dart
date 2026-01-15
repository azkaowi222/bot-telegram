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
  double keyboarHeight = 0;
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    // print('Halaman stocks dipanggil');
    final azureAccounts =
        controller.accountStocks.where((acc) {
          return acc.category.contains('Azure');
        }).toList();
    // for (var element in azureAccounts) {
    //   print(element.email);
    // }
    final digitalOceanAccounts = controller.accountStocks.where((acc) {
      return acc.category.contains('DigitalOcean');
    });
    final awsAccounts = controller.accountStocks.where((acc) {
      return acc.category.contains('Aws');
    });
    final linodeAccounts = controller.accountStocks.where((acc) {
      return acc.category.contains('Linode');
    });
    final ghsAccount = controller.accountStocks.where((acc) {
      return acc.category.contains('Github');
    });
    final edumailAccount = controller.accountStocks.where((acc) {
      return acc.category.contains('Edumail');
    });

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
                                Text(account.name),
                                GestureDetector(
                                  onTap: () {
                                    keyboarHeight = 0;
                                    _formKey.currentState?.reset();
                                    emailController.clear();
                                    passwordController.clear();
                                    metadataController.clear();
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(
                                          builder: (context, setBottomState) {
                                            return Container(
                                              padding: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                                top: 12,
                                                bottom: keyboarHeight + 50,
                                              ),
                                              width: double.infinity,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
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
                                                      SizedBox(width: 5),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                          top: 3,
                                                        ),
                                                        child: Text(
                                                          'Add stock',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Align(
                                                          alignment:
                                                              Alignment
                                                                  .centerRight,
                                                          child: GestureDetector(
                                                            onTap: () async {
                                                              if (_formKey
                                                                  .currentState!
                                                                  .validate()) {
                                                                final AccountStock
                                                                newAccount = AccountStock(
                                                                  product: {
                                                                    'id':
                                                                        account
                                                                            .id,
                                                                  },
                                                                  email:
                                                                      emailController
                                                                          .text,
                                                                  password:
                                                                      passwordController
                                                                          .text,
                                                                  status:
                                                                      'available',
                                                                  createdAt:
                                                                      DateTime.now()
                                                                          .toString(),
                                                                  category:
                                                                      account
                                                                          .category,
                                                                  metadata: {
                                                                    '2fa':
                                                                        metadataController
                                                                            .text,
                                                                  },
                                                                );
                                                                final accountStock =
                                                                    controller
                                                                        .accountStocks
                                                                        .length;
                                                                await controller
                                                                    .addAccountStock(
                                                                      newAccount,
                                                                    );
                                                                final accountStockAfterAdd =
                                                                    controller
                                                                        .accountStocks
                                                                        .length;
                                                                if (context
                                                                    .mounted) {
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
                                                              padding:
                                                                  EdgeInsets.all(
                                                                    8,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                                color:
                                                                    Colors
                                                                        .blue
                                                                        .shade300,
                                                              ),
                                                              margin:
                                                                  EdgeInsets.only(
                                                                    top: 2,
                                                                  ),
                                                              child: Text(
                                                                'Save',
                                                                style:
                                                                    TextStyle(
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
                                                  SizedBox(height: 30),
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
                                                              AutovalidateMode
                                                                  .onUserInteraction,
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return 'Field required';
                                                            }
                                                            return null;
                                                          },

                                                          decoration: InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                ),
                                                            border:
                                                                OutlineInputBorder(),
                                                            labelText:
                                                                'Username/email',
                                                          ),
                                                        ),
                                                        SizedBox(height: 30),
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
                                                              AutovalidateMode
                                                                  .onUserInteraction,
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return 'Field required';
                                                            }
                                                            return null;
                                                          },

                                                          decoration: InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                ),
                                                            border:
                                                                OutlineInputBorder(),
                                                            labelText:
                                                                'Password',
                                                          ),
                                                        ),
                                                        SizedBox(height: 30),
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
                                                              AutovalidateMode
                                                                  .onUserInteraction,
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return 'Field required';
                                                            }
                                                            return null;
                                                          },

                                                          decoration: InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                ),
                                                            border:
                                                                OutlineInputBorder(),
                                                            labelText: '2fa',
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
                            SizedBox(height: 10),
                            ...azureAccounts.map((e) {
                              return account.name.contains(e.category)
                                  ? Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(bottom: 15),
                                    padding: EdgeInsets.symmetric(vertical: 8),
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: deviceWidth * 0.7,
                                                  child: Text(
                                                    'Username/email: ${e.email}',
                                                    softWrap: true,
                                                  ),
                                                ),
                                                Text('Password: ${e.password}'),
                                                SizedBox(
                                                  width: deviceWidth * 0.7,
                                                  child: Text(
                                                    '2fa: ${e.metadata['2fa']}',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              e.status,
                                              style: TextStyle(
                                                color:
                                                    e.status == 'available'
                                                        ? Colors.green.shade300
                                                        : e.status == 'reserved'
                                                        ? Colors.orange
                                                        : Colors.red.shade400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                  : SizedBox();
                            }),
                            ...awsAccounts.map((e) {
                              return account.name.contains(e.category)
                                  ? Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(bottom: 15),
                                    padding: EdgeInsets.symmetric(vertical: 8),
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: deviceWidth * 0.7,
                                                  child: Text(
                                                    'Username/email: ${e.email}',
                                                    softWrap: true,
                                                  ),
                                                ),
                                                Text('Password: ${e.password}'),
                                                SizedBox(
                                                  width: deviceWidth * 0.7,
                                                  child: Text(
                                                    '2fa: ${e.metadata['2fa']}',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              e.status,
                                              style: TextStyle(
                                                color:
                                                    e.status == 'available'
                                                        ? Colors.green.shade300
                                                        : e.status == 'reserved'
                                                        ? Colors.orange
                                                        : Colors.red.shade400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                  : SizedBox();
                            }),
                            ...linodeAccounts.map((e) {
                              return account.name.contains(e.category)
                                  ? Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(bottom: 15),
                                    padding: EdgeInsets.symmetric(vertical: 8),
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: deviceWidth * 0.7,
                                                  child: Text(
                                                    'Username/email: ${e.email}',
                                                    softWrap: true,
                                                  ),
                                                ),
                                                Text('Password: ${e.password}'),
                                                SizedBox(
                                                  width: deviceWidth * 0.7,
                                                  child: Text(
                                                    '2fa: ${e.metadata['2fa']}',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              e.status,
                                              style: TextStyle(
                                                color:
                                                    e.status == 'available'
                                                        ? Colors.green.shade300
                                                        : e.status == 'reserved'
                                                        ? Colors.orange
                                                        : Colors.red.shade400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                  : SizedBox();
                            }),
                            ...digitalOceanAccounts.map((e) {
                              return account.name.contains(e.category)
                                  ? Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(bottom: 15),
                                    padding: EdgeInsets.symmetric(vertical: 8),
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: deviceWidth * 0.7,
                                                  child: Text(
                                                    'Username/email: ${e.email}',
                                                    softWrap: true,
                                                  ),
                                                ),
                                                Text('Password: ${e.password}'),
                                                SizedBox(
                                                  width: deviceWidth * 0.7,
                                                  child: Text(
                                                    '2fa: ${e.metadata['2fa']}',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              e.status,
                                              style: TextStyle(
                                                color:
                                                    e.status == 'available'
                                                        ? Colors.green.shade300
                                                        : e.status == 'reserved'
                                                        ? Colors.orange
                                                        : Colors.red.shade400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                  : SizedBox();
                            }),
                            ...ghsAccount.map((e) {
                              return account.name.contains(e.category)
                                  ? Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(bottom: 15),
                                    padding: EdgeInsets.symmetric(vertical: 8),
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: deviceWidth * 0.7,
                                                  child: Text(
                                                    'Username/email: ${e.email}',
                                                    softWrap: true,
                                                  ),
                                                ),
                                                Text('Password: ${e.password}'),
                                                SizedBox(
                                                  width: deviceWidth * 0.7,
                                                  child: Text(
                                                    '2fa: ${e.metadata['2fa']}',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              e.status,
                                              style: TextStyle(
                                                color:
                                                    e.status == 'available'
                                                        ? Colors.green.shade300
                                                        : e.status == 'reserved'
                                                        ? Colors.orange
                                                        : Colors.red.shade400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                  : SizedBox();
                            }),
                            ...edumailAccount.map((e) {
                              return account.name.contains(e.category)
                                  ? Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(bottom: 15),
                                    padding: EdgeInsets.symmetric(vertical: 8),
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: deviceWidth * 0.7,
                                                  child: Text(
                                                    'Username/email: ${e.email}',
                                                    softWrap: true,
                                                  ),
                                                ),
                                                Text('Password: ${e.password}'),
                                                SizedBox(
                                                  width: deviceWidth * 0.7,
                                                  child: Text(
                                                    '2fa: ${e.metadata['2fa']}',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              e.status,
                                              style: TextStyle(
                                                color:
                                                    e.status == 'available'
                                                        ? Colors.green.shade300
                                                        : e.status == 'reserved'
                                                        ? Colors.orange
                                                        : Colors.red.shade400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                  : SizedBox();
                            }),
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
