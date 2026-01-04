import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'كافتيريا الخير',
      theme: ThemeData(
        fontFamily: 'Cairo',
        primaryColor: Color(0xFF2E7D32),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          elevation: 4,
          centerTitle: true,
        ),
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _cart = [];
  String _selectedCategory = 'الكل';
  bool _isLoading = true;

  // المنتجات الافتراضية
  final List<Map<String, dynamic>> _defaultProducts = [
    {
      'id': '1',
      'name': 'عصير برتقال طازج',
      'description': 'عصير برتقال طبيعي 100% مع قطع البرتقال',
      'price': 1500,
      'category': 'عصائر طازجة',
      'imageUrl': 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400',
      'isAvailable': true,
      'isFeatured': true,
    },
    {
      'id': '2',
      'name': 'سندوتش شاورما دجاج',
      'description': 'شاورما دجاج مع الخضار والصلصة الخاصة',
      'price': 2500,
      'category': 'سندوتشات',
      'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
      'isAvailable': true,
      'isFeatured': true,
    },
    {
      'id': '3',
      'name': 'كيك الشوكولاتة',
      'description': 'كيك شوكولاتة طري مع طبقة من الكريمة',
      'price': 1200,
      'category': 'حلويات',
      'imageUrl': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w-400',
      'isAvailable': true,
      'isFeatured': false,
    },
    {
      'id': '4',
      'name': 'قهوة تركية',
      'description': 'قهوة تركية أصيلة مع الهيل',
      'price': 1000,
      'category': 'مشروبات ساخنة',
      'imageUrl': 'https://images.unsplash.com/photo-1498804103079-a6351b050096?w=400',
      'isAvailable': true,
      'isFeatured': true,
    },
    {
      'id': '5',
      'name': 'سندوتش جبنة مشوية',
      'description': 'جبنة شيدر مع الخضار المشوية',
      'price': 1800,
      'category': 'سندوتشات',
      'imageUrl': 'https://images.unsplash.com/photo-1481070555726-e2fe8357725c?w=400',
      'isAvailable': true,
      'isFeatured': false,
    },
    {
      'id': '6',
      'name': 'عصير فراولة طازج',
      'description': 'عصير فراولة طبيعي مع قطع الفراولة',
      'price': 1700,
      'category': 'عصائر طازجة',
      'imageUrl': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400',
      'isAvailable': true,
      'isFeatured': true,
    },
    {
      'id': '7',
      'name': 'بيتزا صغيرة',
      'description': 'بيتزا بالجبنة والزيتون والفطر',
      'price': 3000,
      'category': 'وجبات خفيفة',
      'imageUrl': 'https://images.unsplash.com/photo-1604068549290-dea0e4a305ca?w=400',
      'isAvailable': true,
      'isFeatured': false,
    },
    {
      'id': '8',
      'name': 'شاي بالنعناع',
      'description': 'شاي أخضر مع النعناع الطازج',
      'price': 800,
      'category': 'مشروبات ساخنة',
      'imageUrl': 'https://images.unsplash.com/photo-1597318181409-cf64d0b5d8a2?w=400',
      'isAvailable': true,
      'isFeatured': false,
    },
    {
      'id': '9',
      'name': 'سموذي المانجو',
      'description': 'سموذي مانجو طازج مع الحليب',
      'price': 1900,
      'category': 'عصائر طازجة',
      'imageUrl': 'https://images.unsplash.com/photo-1553530666-ba11d6d136f6?w=400',
      'isAvailable': true,
      'isFeatured': true,
    },
    {
      'id': '10',
      'name': 'برجر دجاج',
      'description': 'برجر دجاج مع الخس والطماطم',
      'price': 2800,
      'category': 'سندوتشات',
      'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      'isAvailable': true,
      'isFeatured': true,
    },
    {
      'id': '11',
      'name': 'كنافة بالنوتيلا',
      'description': 'كنافة مقرمشة مع شوكولاتة النوتيلا',
      'price': 2200,
      'category': 'حلويات',
      'imageUrl': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',
      'isAvailable': true,
      'isFeatured': false,
    },
    {
      'id': '12',
      'name': 'كابتشينو',
      'description': 'كابتشينو إيطالي مع رغوة الحليب',
      'price': 1500,
      'category': 'مشروبات ساخنة',
      'imageUrl': 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=400',
      'isAvailable': true,
      'isFeatured': true,
    },
  ];

  final List<String> _categories = [
    'الكل',
    'عصائر طازجة',
    'سندوتشات',
    'وجبات خفيفة',
    'مشروبات ساخنة',
    'حلويات',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(Duration(milliseconds: 500)); // محاكاة التحميل
    
    final prefs = await SharedPreferences.getInstance();
    final savedProducts = prefs.getString('products');
    final savedCart = prefs.getString('cart');
    
    setState(() {
      if (savedProducts != null && savedProducts.isNotEmpty) {
        _products = List<Map<String, dynamic>>.from(json.decode(savedProducts));
      } else {
        _products = _defaultProducts;
        _saveProducts();
      }
      
      if (savedCart != null) {
        _cart = List<Map<String, dynamic>>.from(json.decode(savedCart));
      }
      
      _isLoading = false;
    });
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('products', json.encode(_products));
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', json.encode(_cart));
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      _cart.add({...product, 'cartId': DateTime.now().millisecondsSinceEpoch.toString()});
    });
    _saveCart();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إضافة ${product['name']} إلى السلة',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
    _saveCart();
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
    });
    _saveCart();
  }

  double _calculateTotal() {
    return _cart.fold(0, (sum, item) => sum + (item['price'] as num).toDouble());
  }

  Future<void> _sendOrder() async {
    if (_cart.isEmpty) return;
    
    String message = '🌟 *طلب جديد - كافتيريا الخير* 🌟\n\n';
    message += '*تفاصيل الطلب:*\n\n';
    
    Map<String, int> itemCount = {};
    for (var item in _cart) {
      itemCount[item['name']] = (itemCount[item['name']] ?? 0) + 1;
    }
    
    itemCount.forEach((name, count) {
      var item = _cart.firstWhere((i) => i['name'] == name);
      message += '✅ ${count}x $name - ${item['price'] * count} ريال\n';
    });
    
    message += '\n*المجموع:* ${_calculateTotal()} ريال\n';
    message += '----------------\n';
    message += '*📍 العنوان:* تعز - دمنة خدير - امام الملك فون\n';
    message += '*📞 رقم التواصل:* +967730528609\n';
    message += '*⏰ نعمل 24 ساعة*\n';
    message += 'شكراً لثقتكم بكافتيريا الخير 🌹';
    
    String url = 'https://wa.me/967730528609?text=${Uri.encodeComponent(message)}';
    
    if (await canLaunch(url)) {
      await launch(url);
      _clearCart();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا يمكن فتح واتساب',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAdminLogin() {
    TextEditingController passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Color(0xFF2E7D32)),
                SizedBox(width: 10),
                Text('دخول المدير', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'كلمة المرور الافتراضية: admin123\nيمكنك تغييرها في الكود',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
              ),
              ElevatedButton(
                onPressed: () {
                  if (passwordController.text == 'admin123') {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminPanel()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'كلمة المرور غير صحيحة',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text('دخول', style: TextStyle(fontFamily: 'Cairo')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E7D32),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategory == 'الكل') return _products;
    return _products.where((p) => p['category'] == _selectedCategory).toList();
  }

  List<Map<String, dynamic>> get _featuredProducts {
    return _products.where((p) => p['isFeatured'] == true).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'كافتيريا الخير',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: Icon(Icons.admin_panel_settings, color: Colors.white),
            onPressed: _showAdminLogin,
            tooltip: 'دخول المدير',
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () => _showCartDialog(),
                tooltip: 'سلة المشتريات',
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '${_cart.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  SizedBox(height: 20),
                  Text(
                    'جاري التحميل...',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 16),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // معلومات الكافتيريا
                Container(
                  padding: EdgeInsets.all(12),
                  color: Colors.green[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.access_time, color: Color(0xFF2E7D32)),
                          Text('24 ساعة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.location_on, color: Color(0xFF2E7D32)),
                          Text('تعز - دمنة خدير', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.phone, color: Color(0xFF2E7D32)),
                          Text('+967730528609', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // فئات المنتجات
                Container(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return _buildCategoryChip(_categories[index]);
                    },
                  ),
                ),
                
                // المنتجات المميزة (إن وجدت)
                if (_selectedCategory == 'الكل' && _featuredProducts.isNotEmpty)
                  Container(
                    height: 220,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '🏆 المنتجات المميزة',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _featuredProducts.length,
                            itemBuilder: (context, index) {
                              return _buildFeaturedProductCard(_featuredProducts[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // قائمة المنتجات
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_cafe, size: 80, color: Colors.grey[300]),
                              SizedBox(height: 20),
                              Text(
                                'لا توجد منتجات في هذا القسم',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(12),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(_filteredProducts[index]);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: _cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _sendOrder,
              icon: Icon(Icons.whatsapp, color: Colors.white),
              label: Text(
                'إرسال الطلب (${_calculateTotal()} ريال)',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
            )
          : null,
    );
  }

  Widget _buildCategoryChip(String category) {
    bool isSelected = _selectedCategory == category;
    
    return Padding(
      padding: EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF2E7D32) : Colors.grey[100],
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? Color(0xFF2E7D32) : Colors.grey[300],
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (category == 'عصائر طازجة') Icon(Icons.local_drink, size: 18, color: isSelected ? Colors.white : Colors.green),
              if (category == 'سندوتشات') Icon(Icons.fastfood, size: 18, color: isSelected ? Colors.white : Colors.orange),
              if (category == 'حلويات') Icon(Icons.cake, size: 18, color: isSelected ? Colors.white : Colors.pink),
              if (category == 'مشروبات ساخنة') Icon(Icons.coffee, size: 18, color: isSelected ? Colors.white : Colors.brown),
              if (category == 'وجبات خفيفة') Icon(Icons.restaurant, size: 18, color: isSelected ? Colors.white : Colors.red),
              SizedBox(width: category != 'الكل' ? 6 : 0),
              Text(
                category,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    bool isInCart = _cart.any((item) => item['id'] == product['id']);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // صورة المنتج
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: product['imageUrl'] != null && product['imageUrl'].isNotEmpty
                      ? Image.network(
                          product['imageUrl'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.fastfood, size: 40, color: Colors.grey),
                                    SizedBox(height: 10),
                                    Text(
                                      'صورة المنتج',
                                      style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.fastfood, size: 40, color: Colors.grey),
                                SizedBox(height: 10),
                                Text(
                                  'صورة المنتج',
                                  style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              
              // معلومات المنتج
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product['name'],
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (product['isFeatured'] == true)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'مميز',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[900],
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      product['description'],
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product['price']} ريال',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isInCart ? Icons.check_circle : Icons.add_shopping_cart,
                            color: isInCart ? Colors.green : Color(0xFF2E7D32),
                            size: 22,
                          ),
                          onPressed: () {
                            if (!isInCart) {
                              _addToCart(product);
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          tooltip: isInCart ? 'مضاف للسلة' : 'إضافة للسلة',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // شارة القسم
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                _getCategoryIcon(product['category']) + ' ' + product['category'],
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getCategoryColor(product['category']),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProductCard(Map<String, dynamic> product) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(left: 12, right: 12),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            // صورة المنتج المميز
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: product['imageUrl'] != null && product['imageUrl'].isNotEmpty
                    ? Image.network(
                        product['imageUrl'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(Icons.fastfood, size: 40, color: Colors.grey),
                        ),
                      ),
              ),
            ),
            
            // معلومات المنتج المميز
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${product['price']} ريال',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(product),
                      child: Text(
                        'أضف للسلة',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E7D32),
                        padding: EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'عصائر طازجة': return '🥤';
      case 'سندوتشات': return '🥪';
      case 'حلويات': return '🍰';
      case 'مشروبات ساخنة': return '☕';
      case 'وجبات خفيفة': return '🍕';
      default: return '🍽️';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'عصائر طازجة': return Colors.green;
      case 'سندوتشات': return Colors.orange;
      case 'حلويات': return Colors.pink;
      case 'مشروبات ساخنة': return Colors.brown;
      case 'وجبات خفيفة': return Colors.red;
      default: return Colors.blue;
    }
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Row(
              children: [
                Icon(Icons.shopping_cart, color: Color(0xFF2E7D32)),
                SizedBox(width: 10),
                Text('سلة المشتريات', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                Spacer(),
                if (_cart.isNotEmpty)
                  TextButton(
                    onPressed: _clearCart,
                    child: Text(
                      'تفريغ السلة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(maxHeight: 400),
              child: _cart.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey[300]),
                          SizedBox(height: 20),
                          Text(
                            'السلة فارغة',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'أضف منتجات من القائمة',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        for (var i = 0; i < _cart.length; i++)
                          Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: _cart[i]['imageUrl'] != null && _cart[i]['imageUrl'].isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(_cart[i]['imageUrl']),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: Colors.grey[100],
                                ),
                                child: _cart[i]['imageUrl'] == null || _cart[i]['imageUrl'].isEmpty
                                    ? Center(child: Icon(Icons.fastfood, size: 24, color: Colors.grey))
                                    : null,
                              ),
                              title: Text(
                                _cart[i]['name'],
                                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${_cart[i]['price']} ريال',
                                style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF2E7D32)),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => _removeFromCart(i),
                                tooltip: 'إزالة',
                              ),
                            ),
                          ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'المجموع:',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_calculateTotal()} ريال',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            actions: _cart.isEmpty
                ? [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('إغلاق', style: TextStyle(fontFamily: 'Cairo')),
                    ),
                  ]
                : [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('متابعة التسوق', style: TextStyle(fontFamily: 'Cairo')),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _sendOrder();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.whatsapp, size: 20),
                          SizedBox(width: 8),
                          Text('إرسال الطلب', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
          ),
        );
      },
    );
  }
}
// لوحة تحكم المدير
class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedProducts = prefs.getString('products');
    
    setState(() {
      if (savedProducts != null && savedProducts.isNotEmpty) {
        _products = List<Map<String, dynamic>>.from(json.decode(savedProducts));
      }
      _isLoading = false;
    });
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('products', json.encode(_products));
  }

  Future<void> _addProduct() async {
    await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AddProductDialog(
          onAdd: (newProduct) async {
            setState(() {
              _products.insert(0, {
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                ...newProduct,
              });
            });
            await _saveProducts();
          },
        ),
      ),
    );
  }

  Future<void> _editProduct(int index) async {
    await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: EditProductDialog(
          product: _products[index],
          onEdit: (editedProduct) async {
            setState(() {
              _products[index] = editedProduct;
            });
            await _saveProducts();
          },
        ),
      ),
    );
  }

  Future<void> _deleteProduct(int index) async {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('تأكيد الحذف', style: TextStyle(fontFamily: 'Cairo')),
          content: Text(
            'هل أنت متأكد من حذف ${_products[index]['name']}؟',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _products.removeAt(index);
                });
                await _saveProducts();
                Navigator.pop(context);
              },
              child: Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFeatured(int index) async {
    setState(() {
      _products[index]['isFeatured'] = !(_products[index]['isFeatured'] ?? false);
    });
    await _saveProducts();
  }

  Future<void> _toggleAvailable(int index) async {
    setState(() {
      _products[index]['isAvailable'] = !(_products[index]['isAvailable'] ?? true);
    });
    await _saveProducts();
  }

  Widget _buildProductsPage() {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            )
          : RefreshIndicator(
              onRefresh: _loadProducts,
              color: Color(0xFF2E7D32),
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: _products[index]['imageUrl'] != null &&
                                  _products[index]['imageUrl'].isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(_products[index]['imageUrl']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: Colors.grey[100],
                        ),
                        child: _products[index]['imageUrl'] == null ||
                                _products[index]['imageUrl'].isEmpty
                            ? Center(child: Icon(Icons.fastfood, color: Colors.grey))
                            : null,
                      ),
                      title: Text(
                        _products[index]['name'],
                        style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_products[index]['price']} ريال',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _products[index]['category'],
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _products[index]['isFeatured'] == true
                                  ? Icons.star
                                  : Icons.star_border,
                              color: _products[index]['isFeatured'] == true
                                  ? Colors.amber
                                  : Colors.grey,
                            ),
                            onPressed: () => _toggleFeatured(index),
                            tooltip: 'تغيير التميز',
                          ),
                          IconButton(
                            icon: Icon(
                              _products[index]['isAvailable'] == true
                                  ? Icons.check_circle
                                  : Icons.remove_circle,
                              color: _products[index]['isAvailable'] == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            onPressed: () => _toggleAvailable(index),
                            tooltip: 'التوفر',
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editProduct(index),
                            tooltip: 'تعديل',
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProduct(index),
                            tooltip: 'حذف',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  Widget _buildCategoriesPage() {
    final categories = _products.map((p) => p['category']).toSet().toList();
    
    return Scaffold(
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final categoryProducts =
              _products.where((p) => p['category'] == category).toList();
          
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ExpansionTile(
              leading: Icon(
                _getCategoryIconData(category),
                color: _getCategoryColor(category),
              ),
              title: Text(
                category,
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${categoryProducts.length} منتج',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              children: categoryProducts.map((product) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: product['imageUrl'] != null &&
                            product['imageUrl'].isNotEmpty
                        ? NetworkImage(product['imageUrl'])
                        : null,
                    child: product['imageUrl'] == null || product['imageUrl'].isEmpty
                        ? Icon(Icons.fastfood)
                        : null,
                  ),
                  title: Text(product['name'], style: TextStyle(fontFamily: 'Cairo')),
                  subtitle: Text('${product['price']} ريال',
                      style: TextStyle(fontFamily: 'Cairo')),
                  trailing: Text(
                    product['isAvailable'] == true ? 'متاح' : 'غير متاح',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: product['isAvailable'] == true ? Colors.green : Colors.red,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIconData(String category) {
    switch (category) {
      case 'عصائر طازجة': return Icons.local_drink;
      case 'سندوتشات': return Icons.fastfood;
      case 'حلويات': return Icons.cake;
      case 'مشروبات ساخنة': return Icons.coffee;
      case 'وجبات خفيفة': return Icons.restaurant;
      default: return Icons.category;
    }
  }

  Widget _buildOrdersPage() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 80, color: Colors.grey[300]),
            SizedBox(height: 20),
            Text(
              'الطلبات تصل مباشرة على واتساب',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              '📱 +967730528609',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green[100]!),
              ),
              child: Column(
                children: [
                  Text(
                    'معلومات الاستلام',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'الطلبات تصل مباشرة على واتساب\nيمكنك الرد وتأكيد الطلب',
                    style: TextStyle(fontFamily: 'Cairo'),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPage() {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.store, color: Color(0xFF2E7D32)),
            title: Text('معلومات الكافتيريا', style: TextStyle(fontFamily: 'Cairo')),
            subtitle: Text('تعديل المعلومات الأساسية', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ListTile(
            leading: Icon(Icons.phone, color: Color(0xFF2E7D32)),
            title: Text('رقم واتساب', style: TextStyle(fontFamily: 'Cairo')),
            subtitle: Text('+967730528609', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ListTile(
            leading: Icon(Icons.access_time, color: Color(0xFF2E7D32)),
            title: Text('ساعات العمل', style: TextStyle(fontFamily: 'Cairo')),
            subtitle: Text('24 ساعة', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ListTile(
            leading: Icon(Icons.location_on, color: Color(0xFF2E7D32)),
            title: Text('العنوان', style: TextStyle(fontFamily: 'Cairo')),
            subtitle: Text('تعز - دمنة خدير - امام الملك فون',
                style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لوحة تحكم المدير',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF2E7D32),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildProductsPage(),
          _buildCategoriesPage(),
          _buildOrdersPage(),
          _buildSettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontFamily: 'Cairo'),
        unselectedLabelStyle: TextStyle(fontFamily: 'Cairo'),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'المنتجات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'الأقسام',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'الطلبات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}

class AddProductDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const AddProductDialog({Key key, this.onAdd}) : super(key: key);

  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _selectedCategory = 'عصائر طازجة';
  String _selectedImage = '';
  bool _isFeatured = false;
  bool _isAvailable = true;

  final List<String> _categories = [
    'عصائر طازجة',
    'سندوتشات',
    'وجبات خفيفة',
    'مشروبات ساخنة',
    'حلويات',
  ];

  final List<String> _sampleImages = [
    'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400', // عصير
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400', // شاورما
    'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400', // كيك
    'https://images.unsplash.com/photo-1498804103079-a6351b050096?w=400', // قهوة
    'https://images.unsplash.com/photo-1481070555726-e2fe8357725c?w=400', // سندوتش جبنة
    'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400', // عصير فراولة
    'https://images.unsplash.com/photo-1604068549290-dea0e4a305ca?w=400', // بيتزا
    'https://images.unsplash.com/photo-1597318181409-cf64d0b5d8a2?w=400', // شاي
    'https://images.unsplash.com/photo-1553530666-ba11d6d136f6?w=400', // سموذي
    'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400', // برجر
    'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400', // كنافة
    'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=400', // كابتشينو
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.add_circle, color: Color(0xFF2E7D32)),
          SizedBox(width: 10),
          Text('إضافة منتج جديد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // اختيار صورة
              Text('اختر صورة:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                height: 120,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _sampleImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = _sampleImages[index];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedImage == _sampleImages[index] 
                                ? Color(0xFF2E7D32) 
                                : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(_sampleImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: _selectedImage == _sampleImages[index]
                            ? Container(
                                color: Colors.green.withOpacity(0.3),
                                child: Center(
                                  child: Icon(Icons.check_circle, color: Colors.white, size: 30),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              
              // اسم المنتج
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسم المنتج *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.fastfood),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                style: TextStyle(fontFamily: 'Cairo'),
                validator: (value) => value.isEmpty ? 'يرجى إدخال اسم المنتج' : null,
              ),
              SizedBox(height: 12),
              
              // وصف المنتج
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'وصف المنتج',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.description),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                style: TextStyle(fontFamily: 'Cairo'),
                maxLines: 3,
              ),
              SizedBox(height: 12),
              
              // السعر
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'السعر (ريال يمني) *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.money),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                style: TextStyle(fontFamily: 'Cairo'),
                keyboardType: TextInputType.number,
                validator: (value) => value.isEmpty ? 'يرجى إدخال السعر' : null,
              ),
              SizedBox(height: 12),
              
              // القسم
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[50],
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'القسم *',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category, style: TextStyle(fontFamily: 'Cairo')),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
              SizedBox(height: 12),
              
              // خيارات إضافية
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('منتج مميز', style: TextStyle(fontFamily: 'Cairo')),
                      value: _isFeatured,
                      onChanged: (value) {
                        setState(() {
                          _isFeatured = value;
                        });
                      },
                      secondary: Icon(Icons.star, color: Colors.amber),
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('متاح للطلب', style: TextStyle(fontFamily: 'Cairo')),
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
                      secondary: Icon(Icons.check_circle, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState.validate()) {
              if (_selectedImage.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('يرجى اختيار صورة للمنتج', style: TextStyle(fontFamily: 'Cairo')),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              widget.onAdd({
                'name': _nameController.text,
                'description': _descController.text,
                'price': int.parse(_priceController.text),
                'category': _selectedCategory,
                'imageUrl': _selectedImage,
                'isFeatured': _isFeatured,
                'isAvailable': _isAvailable,
              });
              
              Navigator.pop(context);
            }
          },
          child: Text('إضافة المنتج', style: TextStyle(fontFamily: 'Cairo')),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2E7D32),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class EditProductDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) onEdit;

  const EditProductDialog({Key key, this.product, this.onEdit}) : super(key: key);

  @override
  _EditProductDialogState createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _selectedCategory;
  String _selectedImage;
  bool _isFeatured;
  bool _isAvailable;

  final List<String> _categories = [
    'عصائر طازجة',
    'سندوتشات',
    'وجبات خفيفة',
    'مشروبات ساخنة',
    'حلويات',
  ];

  final List<String> _sampleImages = [
    'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
    'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400',
    'https://images.unsplash.com/photo-1498804103079-a6351b050096?w=400',
    'https://images.unsplash.com/photo-1481070555726-e2fe8357725c?w=400',
    'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400',
    'https://images.unsplash.com/photo-1604068549290-dea0e4a305ca?w=400',
    'https://images.unsplash.com/photo-1597318181409-cf64d0b5d8a2?w=400',
    'https://images.unsplash.com/photo-1553530666-ba11d6d136f6?w=400',
    'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
    'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',
    'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=400',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product['name'];
    _descController.text = widget.product['description'];
    _priceController.text = widget.product['price'].toString();
    _selectedCategory = widget.product['category'];
    _selectedImage = widget.product['imageUrl'];
    _isFeatured = widget.product['isFeatured'] ?? false;
    _isAvailable = widget.product['isAvailable'] ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, color: Color(0xFF2E7D32)),
          SizedBox(width: 10),
          Text('تعديل المنتج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // اختيار صورة
              Text('صورة المنتج:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                height: 120,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _sampleImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = _sampleImages[index];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedImage == _sampleImages[index] 
                                ? Color(0xFF2E7D32) 
                                : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(_sampleImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: _selectedImage == _sampleImages[index]
                            ? Container(
                                color: Colors.green.withOpacity(0.3),
                                child: Center(
                                  child: Icon(Icons.check_circle, color: Colors.white, size: 30),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Text(
                'الصورة الحالية:',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 5),
              Image.network(widget.product['imageUrl'], height: 60, fit: BoxFit.cover),
              SizedBox(height: 20),
              
              // اسم المنتج
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسم المنتج *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.fastfood),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                style: TextStyle(fontFamily: 'Cairo'),
                validator: (value) => value.isEmpty ? 'يرجى إدخال اسم المنتج' : null,
              ),
              SizedBox(height: 12),
              
              // وصف المنتج
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'وصف المنتج',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.description),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                style: TextStyle(fontFamily: 'Cairo'),
                maxLines: 3,
              ),
              SizedBox(height: 12),
              
              // السعر
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'السعر (ريال يمني) *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.money),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                style: TextStyle(fontFamily: 'Cairo'),
                keyboardType: TextInputType.number,
                validator: (value) => value.isEmpty ? 'يرجى إدخال السعر' : null,
              ),
              SizedBox(height: 12),
              
              // القسم
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[50],
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'القسم *',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category, style: TextStyle(fontFamily: 'Cairo')),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
              SizedBox(height: 12),
              
              // خيارات إضافية
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('منتج مميز', style: TextStyle(fontFamily: 'Cairo')),
                      value: _isFeatured,
                      onChanged: (value) {
                        setState(() {
                          _isFeatured = value;
                        });
                      },
                      secondary: Icon(Icons.star, color: Colors.amber),
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('متاح للطلب', style: TextStyle(fontFamily: 'Cairo')),
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
                      secondary: Icon(Icons.check_circle, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState.validate()) {
              widget.onEdit({
                ...widget.product,
                'name': _nameController.text,
                'description': _descController.text,
                'price': int.parse(_priceController.text),
                'category': _selectedCategory,
                'imageUrl': _selectedImage,
                'isFeatured': _isFeatured,
                'isAvailable': _isAvailable,
              });
              
              Navigator.pop(context);
            }
          },
          child: Text('حفظ التعديلات', style: TextStyle(fontFamily: 'Cairo')),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2E7D32),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
