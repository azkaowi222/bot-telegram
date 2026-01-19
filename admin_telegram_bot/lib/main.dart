import 'package:admin_telegram_bot/controllers/product_controller.dart';
import 'package:admin_telegram_bot/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'views/home.dart';
import 'views/orders_history.dart';
import 'views/products.dart';
import 'views/stocks.dart';
import 'views/account.dart';

enum Status { active, inactive }

Future main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Gilroy',
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontWeight: FontWeight.w400),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    productController.getAllProducts();
  }

  final ProductController productController = ProductController();

  int _currentIndex = 0;
  final List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      tooltip: 'Home',
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.history_outlined),
      tooltip: 'Order History',
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_rounded),
      tooltip: 'Product Management',
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.dataset_linked_sharp),
      tooltip: 'Stocks',
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_circle_outlined),
      tooltip: 'Account',
      label: '',
    ),
  ];

  final _formKey = GlobalKey<FormState>();

  Status? _selectedMethod = Status.active;
  String category = '';
  int? price = 0;
  String productName = '';
  double balance = 0;
  String description = '';
  // String id = ''

  void resetForm() {
    _formKey.currentState?.reset();
    productName = '';
    description = '';
    category = '';
    price = 0;
    balance = 0;

    if (productController.images != null) {
      productController.images!.deleteSync();
      productController.images = null;
    }

    setState(() {});
  }

  final TextEditingController categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final productCategories =
        productController.products.map((product) {
          return product.category;
        }).toList();
    productCategories.add('New categorie');
    final num deviceHeight = MediaQuery.of(context).size.height;
    final num deviceWidth = MediaQuery.of(context).size.width;
    final List<Widget> pages = [
      const HomePage(),
      const OrderHistoryPage(status: 'all'),
      Products(controller: productController),
      const StocksPage(),
      const AccountPage(),
    ];
    return DefaultTabController(
      length: 4, // Jumlah Tab (All, Paid, Pending, Expired)
      // Gunakan satu Scaffold utama untuk semua halaman
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton:
            _currentIndex == 2
                ? Container(
                  // padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.add),
                    color: Colors.white,
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        useSafeArea: true,
                        barrierLabel: 'Modal',
                        context: context,
                        builder: (_) {
                          return StatefulBuilder(
                            builder: (context, seBottomState) {
                              return Container(
                                // height: deviceHeight.toDouble(),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(14),
                                  ),
                                ),
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 18,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          icon: Icon(Icons.arrow_back),
                                        ),
                                        Text(
                                          'Add Product',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 30),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Media',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),

                                            SizedBox(height: 5),
                                            GestureDetector(
                                              // icon: const Icon(Icons.photo),
                                              child: Container(
                                                // padding: EdgeInsets.all(4.0),
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.0,
                                                      ),
                                                  border: Border.all(
                                                    width: 1.5,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.2),
                                                  ),
                                                ),
                                                child: ListTile(
                                                  trailing: Icon(
                                                    Icons.arrow_forward_ios,
                                                  ),
                                                  title: Text('Add media'),
                                                  subtitle: Text(
                                                    'Add media for this product',
                                                  ),
                                                  leading:
                                                      productController
                                                                  .images ==
                                                              null
                                                          ? CircleAvatar(
                                                            backgroundColor:
                                                                Colors.grey
                                                                    .withValues(
                                                                      alpha:
                                                                          0.3,
                                                                    ),
                                                            child: Icon(
                                                              Icons.perm_media,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          )
                                                          : AspectRatio(
                                                            aspectRatio: 1,
                                                            child: Card(
                                                              clipBehavior:
                                                                  Clip.antiAlias,
                                                              child: Image.file(
                                                                productController
                                                                    .images!,
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                              ),
                                                            ),
                                                          ),
                                                ),
                                              ),
                                              onTap: () async {
                                                await productController
                                                    .pickImage(
                                                      source:
                                                          ImageSource.gallery,
                                                    );
                                                seBottomState(() {});
                                              },
                                            ),
                                            SizedBox(height: 30),
                                            Text(
                                              'Product Title',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            TextField(
                                              onTapOutside: (_) {
                                                FocusScope.of(
                                                  context,
                                                ).unfocus();
                                              },
                                              onChanged: (value) {
                                                productName = value;
                                              },
                                              decoration: InputDecoration(
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        width: 2.0,
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.5,
                                                            ),
                                                      ),
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        width: 2.0,
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                      ),
                                                    ),

                                                hintText: 'Enter product title',
                                              ),
                                            ),

                                            SizedBox(height: 30),

                                            Text(
                                              'Status',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8.0,
                                                          ),
                                                      border: Border.all(
                                                        width: 1.5,
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Radio<Status>(
                                                          value: Status.active,
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                          // selected: true,
                                                          groupValue:
                                                              _selectedMethod,
                                                          onChanged: (value) {
                                                            seBottomState(
                                                              () =>
                                                                  _selectedMethod =
                                                                      value,
                                                            );
                                                          },
                                                        ),
                                                        Text('Active'),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 30),
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8.0,
                                                          ),
                                                      border: Border.all(
                                                        width: 1.5,
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Radio<Status>(
                                                          value:
                                                              Status.inactive,

                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                          // selected: true,
                                                          groupValue:
                                                              _selectedMethod,
                                                          onChanged: (value) {
                                                            seBottomState(
                                                              () =>
                                                                  _selectedMethod =
                                                                      value,
                                                            );
                                                          },
                                                        ),
                                                        Text('Inactive'),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: 30),
                                            Text(
                                              'Product description',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 5),

                                            TextField(
                                              onChanged:
                                                  (value) =>
                                                      description = value,
                                              decoration: InputDecoration(
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        width: 2.0,
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.5,
                                                            ),
                                                      ),
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        width: 2.0,
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                      ),
                                                    ),
                                                hintText:
                                                    'Product description (Opsional)',
                                              ),
                                              // maxLines: null,
                                              minLines: 4,

                                              maxLines: null,
                                              textInputAction:
                                                  TextInputAction.done,
                                            ),
                                            SizedBox(height: 30),
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.symmetric(
                                                  horizontal: BorderSide(
                                                    width: 2,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.2),
                                                  ),
                                                ),
                                              ),
                                              child: ListTile(
                                                leading: Icon(Icons.dataset),
                                                title: Text('Category'),
                                                subtitle: Text(
                                                  category.isEmpty
                                                      ? 'Add category'
                                                      : '- $category',
                                                ),
                                                trailing: PopupMenuButton(
                                                  color: Colors.white,

                                                  offset: const Offset(0, 40),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.add),
                                                      SizedBox(width: 3),
                                                      Text(
                                                        'Add',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          height: 3.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  itemBuilder: (context) {
                                                    return productCategories.map((
                                                      categoryProduct,
                                                    ) {
                                                      return PopupMenuItem(
                                                        child: SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: TextButton(
                                                            onPressed: () {
                                                              if (categoryProduct
                                                                  .contains(
                                                                    'New',
                                                                  )) {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (
                                                                    context,
                                                                  ) {
                                                                    return Dialog(
                                                                      shape: OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide.none,
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              2,
                                                                            ),
                                                                      ),
                                                                      child: Container(
                                                                        padding:
                                                                            EdgeInsets.all(
                                                                              8,
                                                                            ),
                                                                        child: Form(
                                                                          key:
                                                                              _formKey,
                                                                          child: TextFormField(
                                                                            onFieldSubmitted: (
                                                                              newValue,
                                                                            ) {
                                                                              seBottomState(
                                                                                () {
                                                                                  category =
                                                                                      newValue;
                                                                                },
                                                                              );
                                                                              Navigator.pop(
                                                                                context,
                                                                              );
                                                                            },
                                                                            decoration: InputDecoration(
                                                                              labelText:
                                                                                  'New category',
                                                                              border:
                                                                                  OutlineInputBorder(),
                                                                            ),
                                                                            autovalidateMode:
                                                                                AutovalidateMode.onUserInteraction,
                                                                            controller:
                                                                                categoryController,
                                                                            validator: (
                                                                              value,
                                                                            ) {
                                                                              if (value!.isEmpty) {
                                                                                return 'Field required';
                                                                              }
                                                                              return null;
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                                return;
                                                              }
                                                              seBottomState(() {
                                                                category =
                                                                    categoryProduct;
                                                              });
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                            },
                                                            child: Text(
                                                              categoryProduct,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList();
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 30),
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.symmetric(
                                                  horizontal: BorderSide(
                                                    width: 2,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.2),
                                                  ),
                                                ),
                                              ),
                                              child: ListTile(
                                                leading: Icon(
                                                  Icons.attach_money_rounded,
                                                ),
                                                title: Text('Price'),
                                                subtitle: Text(
                                                  price == 0
                                                      ? 'Add price'
                                                      : 'Rp. $price',
                                                ),
                                                trailing: GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) {
                                                        final TextEditingController
                                                        priceController =
                                                            TextEditingController();
                                                        return Dialog(
                                                          backgroundColor:
                                                              Colors.white,
                                                          shape: OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide.none,
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                  Radius.circular(
                                                                    8.0,
                                                                  ),
                                                                ),
                                                          ),

                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  12,
                                                                ),
                                                            child: TextField(
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              inputFormatters: [
                                                                FilteringTextInputFormatter
                                                                    .digitsOnly,
                                                              ],
                                                              autofocus: true,
                                                              onSubmitted: (
                                                                value,
                                                              ) {
                                                                seBottomState(() {
                                                                  price =
                                                                      int.tryParse(
                                                                        value,
                                                                      );

                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                });
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                    prefixText:
                                                                        "Rp. ",
                                                                  ),
                                                              controller:
                                                                  priceController,
                                                              onChanged:
                                                                  (value) =>
                                                                      priceController
                                                                              .text =
                                                                          value,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.add),
                                                      SizedBox(width: 3),
                                                      Text(
                                                        'Add',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          height: 3.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 30),
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.symmetric(
                                                  horizontal: BorderSide(
                                                    width: 2,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.2),
                                                  ),
                                                ),
                                              ),
                                              child: ListTile(
                                                leading: Icon(Icons.wallet),
                                                title: Text('Balance'),
                                                subtitle: Text(
                                                  balance == 0
                                                      ? '\$ 0'
                                                      : '\$ ${balance.toString()}',
                                                ),
                                                trailing: PopupMenuButton(
                                                  color: Colors.white,

                                                  offset: const Offset(0, 40),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.add),
                                                      SizedBox(width: 3),
                                                      Text(
                                                        'Add',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          height: 3.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  itemBuilder:
                                                      (context) => [
                                                        PopupMenuItem(
                                                          child: TextButton(
                                                            onPressed: () {
                                                              seBottomState(() {
                                                                balance = 0;
                                                              });
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                            },
                                                            child: Text('0'),
                                                          ),
                                                        ),
                                                        PopupMenuItem(
                                                          child: TextButton(
                                                            onPressed: () {
                                                              seBottomState(() {
                                                                balance = 100;
                                                              });
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                            },
                                                            child: Text('100'),
                                                          ),
                                                        ),
                                                      ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 15),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    style: OutlinedButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 10,
                                                          ),
                                                      side: const BorderSide(
                                                        color: Colors.grey,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.5,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      final ProductModel
                                                      newUser = ProductModel(
                                                        name: productName,
                                                        balance: balance,
                                                        description:
                                                            description,
                                                        price: price!,
                                                        imgPath:
                                                            productController
                                                                .images!
                                                                .path,
                                                        category: category,
                                                        isActive: true,
                                                        createAt:
                                                            DateTime.now()
                                                                .toString(),
                                                      );
                                                      await productController
                                                          .addProduct(newUser);
                                                      resetForm();
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            duration: Duration(
                                                              seconds: 3,
                                                            ),
                                                            content: Text(
                                                              'Product $productName succesfully added.',
                                                            ),
                                                          ),
                                                        );
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 10,
                                                          ),
                                                      backgroundColor:
                                                          Colors.blue[400],
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      elevation: 0,
                                                    ),
                                                    child: const Text(
                                                      'Add Product',

                                                      style: TextStyle(
                                                        // fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
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
                    },
                  ),
                )
                : null,
        backgroundColor: Colors.white,
        // LOGIKA 1: APPBAR (Hanya muncul jika index == 1)
        appBar:
            _currentIndex == 1
                ? AppBar(
                  backgroundColor: Colors.white,
                  title: Align(
                    child: const Text(
                      "Orders History",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  elevation: 0, // Opsional, biar rapi
                  automaticallyImplyLeading:
                      false, // Hilangkan tombol back jika ada
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(30),
                    child: SizedBox(
                      height: 25,

                      child: TabBar(
                        overlayColor: WidgetStatePropertyAll(
                          Colors.transparent,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        isScrollable: true,
                        indicator: BoxDecoration(
                          color:
                              Colors
                                  .brown[800], // Warna Gelap untuk yang AKTIF (Processing)
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Membuat sudut bulat
                        ),
                        tabAlignment: TabAlignment.center,
                        dividerColor: Colors.transparent,
                        // labelStyle: TextStyle(backgroundColor: Colors.blue),
                        labelColor: Colors.white, // Warna teks aktif
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        unselectedLabelColor:
                            Colors.grey, // Warna teks tidak aktif
                        tabs: [
                          _buildTabItem('All'),
                          _buildTabItem('Paid'),
                          _buildTabItem('Pending'),
                          _buildTabItem('Expired'),
                        ],
                      ),
                    ),
                  ),
                )
                : null, // Jika bukan index 1, AppBar dihilangkan (atau ganti AppBar lain)
        // LOGIKA 2: BODY
        body:
            _currentIndex == 1
                ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        // halaman pertama atau halaman all
                        OrderHistoryPage(status: 'all'),
                        OrderHistoryPage(status: 'paid'),
                        OrderHistoryPage(status: 'pending'),
                        OrderHistoryPage(status: 'expired'),

                        // Expanded(child: Text('data')),
                      ],
                    ),
                  ),
                )
                : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    // Pastikan list 'pages' kamu menghandle index selain 1
                    child: pages[_currentIndex],
                  ),
                ),

        // LOGIKA 3: BOTTOM NAVIGATION BAR (Selalu Muncul)
        bottomNavigationBar: Container(
          margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8, top: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.1,
                ), // Gunakan withOpacity untuk kompatibilitas
                blurRadius: 2,
                spreadRadius: 1.4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BottomNavigationBar(
              backgroundColor:
                  Colors.white, // Hapus transparan agar shadow terlihat
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedIconTheme: const IconThemeData(
                color: Colors.black,
                size: 28,
              ),
              unselectedIconTheme: const IconThemeData(color: Colors.blueGrey),
              items: items, // Pastikan variabel 'items' sudah didefinisikan
              currentIndex: _currentIndex,
              onTap:
                  (index) => setState(() {
                    _currentIndex = index;
                  }),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildTabItem(String label) {
  return Container(
    padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 3),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      // Trik: Kasih border tipis ke SEMUA tab.
      // Saat tab aktif, background coklat akan menimpa border ini.
      // border: Border.all(color: Colors.grey.shade300, width: 1),
    ),
    child: Text(label),
  );
}
