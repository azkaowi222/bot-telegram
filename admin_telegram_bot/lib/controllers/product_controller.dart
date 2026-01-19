import 'dart:convert';
import 'dart:io';
import 'package:admin_telegram_bot/models/product_model.dart';
import 'package:flutter/foundation.dart'; // Gunakan ini daripada cupertino untuk ChangeNotifier
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ProductController extends ChangeNotifier {
  final List<ProductModel> _masterData = [];
  final List<String> _categories = [];
  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;
  List<String> get categories => _categories;
  File? _image;
  File? get images => _image;
  set images(File? value) {
    _image = value;
    notifyListeners();
  }

  final ImagePicker _picker = ImagePicker();
  // Pastikan URL ini aktif!
  final String backendUrl = dotenv.get('BACKEND_URL');
  bool isLoading = false;

  Future<void> pickImage({required ImageSource source}) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      debugPrint('images terisi');
      _image = File(pickedFile.path);
    }
  }

  Future<void> getAllProducts() async {
    isLoading = true;
    try {
      print("Mencoba mengambil data...");

      final response = await http.get(
        Uri.parse('$backendUrl/api/products'),
        // Tambahkan Header ini agar tidak dianggap browser oleh Ngrok
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Content-Type": "application/json",
        },
      );

      // print("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Cek dulu apakah body-nya HTML (indikasi error ngrok) atau JSON
        if (response.body.trim().startsWith('<')) {
          print(
            "ERROR: Respons berupa HTML, bukan JSON. Cek URL atau Header Ngrok.",
          );
          return;
        }
        _products.clear();
        _products.clear();
        _masterData.clear();
        _categories.clear();
        final datas = jsonDecode(response.body);
        // print(datas.toString());
        for (final data in datas['data'] as List) {
          _products.add(ProductModel.fromJson(data));
          _masterData.add(ProductModel.fromJson(data));
        }
       
        isLoading = false;
        notifyListeners();
        // print("Data Berhasil: $data");
      } else {
        // print("Request Gagal: ${response.statusCode}");
        print("Body: ${response.body}");
      }
    } catch (e) {
      print("Terjadi Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(ProductModel product) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$backendUrl/api/product'),
    );
    request.fields['name'] = product.name;
    request.fields['price'] = product.price.toString();
    request.fields['description'] = product.description!;
    request.fields['balance'] = product.balance.toString();
    request.fields['category'] = product.category;
    request.fields['isActive'] = product.isActive.toString();

    if (_image != null) {
      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        _image!.path,
      );
      request.files.add(multipartFile);
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = jsonDecode(response.body);

    final ProductModel body = ProductModel.fromJson(data['data']);
    _products.add(body);
    notifyListeners();
    // notifyListeners();
    // debugPrint(request)
  }

  Future<int> editProduct(ProductModel product) async {
    final response = await http.patch(
      Uri.parse('$backendUrl/api/product/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'balance': product.balance,
        'category': product.category,
        'isActive': product.isActive,
      }),
    );
    final json = jsonDecode(response.body);
    final data = json['data'];
    if (response.statusCode != 200) {
      return 400;
    }
    final int index = products.indexWhere((e) {
      return e.id == product.id;
    });
    if (index != -1) {
      products[index] = ProductModel(
        id: product.id,
        name: data['name'],
        balance: product.balance,
        price: product.price,
        category: product.category,
        isActive: product.isActive,
        imgPath: product.imgPath,
      );
    }
    notifyListeners();
    return 200;
  }

  Future<void> deleteProduct({required String name}) async {
    final product =
        products.where((product) {
          return product.name == name;
        }).toList();
    debugPrint(product[0].name);
    final response = await http.delete(
      Uri.parse('$backendUrl/api/product'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'name': product[0].name}),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _products.removeWhere((product) {
        return product.name == name;
      });

      notifyListeners();
    }
  }

  void handleSearch(String value) {
    // 1. Jika kosong, reset filter
    if (value.isEmpty) {
      print(_masterData.length); // Sekarang aman, tetap 6

      // PERBAIKAN: Gunakan List.from untuk menduplikat data
      _products = List.from(_masterData);

      notifyListeners();
      return;
    }

    // 2. Jika ada text search
    // Pastikan Anda memfilter dari _masterData (bukan _products yang mungkin sudah berubah)
    final productContainsValue =
        _masterData.where((ProductModel product) {
          return product.name.toLowerCase().contains(value.toLowerCase());
        }).toList();

    // 3. Masukkan hasil filter
    _products
        .clear(); // Ini aman karena _products sudah terpisah dari _masterData
    _products.addAll(
      productContainsValue,
    ); // Gunakan addAll agar lebih rapi daripada map

    notifyListeners();
  }

  Future<String> sendBroadcast(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/broadcast'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );
      if (response.statusCode != 200) {
        return 'failed to send broadcast';
      }
      final data = jsonDecode(response.body);
      return '${data['status']} send broadcast';
    } catch (e) {
      print('Error exception ${e.toString()}');
      return 'failed to send broadcast';
    }
  }

  // Future<void> getAllCategories() async{
  //   try {
  //     final response = await http.get()
  //   } catch(e) {
  //     print('Error exception: ${e.toString()}');
  //   }
  // }
}
