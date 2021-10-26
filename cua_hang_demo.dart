import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Cua_hang_demo extends StatelessWidget {
  const Cua_hang_demo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Cua_hang(),
    );
  }
}

class Cua_hang extends StatefulWidget {
  const Cua_hang({Key? key}) : super(key: key);

  @override
  _Cua_hangState createState() => _Cua_hangState();
}

class _Cua_hangState extends State<Cua_hang> {
  late Future<List<Product>> lsProduct;

  @override
  void initState() {
    super.initState();
    lsProduct = Product.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sản phẩm trong cửa hàng"),
      ),
      body: FutureBuilder(
        future: lsProduct,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data as List<Product>;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                Product product = data[index];
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        product.image,
                        height: 250,
                      ),
                      Text(
                        product.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Lượt vote: " +
                            product.rating.count.toString() +
                            "  Rate: " +
                            product.rating.rate.toString() + "/5",
                      ),
                      Text(
                        product.price.toString() + " \$",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.green,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {

                        },
                        child: Text("Thêm vào giỏ hàng"),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class Rating {
  final double rate;
  final int count;

  Rating({required this.rate, required this.count});
}

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final Rating rating;

  Product(
      {required this.id,
      required this.title,
      required this.price,
      required this.description,
      required this.category,
      required this.image,
      required this.rating});

  static Future<List<Product>> fetchData() async {
    String url = "https://fakestoreapi.com/products?limit=100";
    var client = http.Client();
    var response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var result = response.body;
      var jsonData = jsonDecode(result);
      List<Product> ls = [];
      for (var item in jsonData) {
        print(item['rate']);
        Rating rating = Rating(
          rate: double.parse(item['rating']['rate'].toString()),
          count: item['rating']['count'],
        );
        Product product = new Product(
            id: item['id'],
            title: item['title'],
            price: double.parse(item['price'].toString()),
            description: item['description'],
            category: item['category'],
            image: item['image'],
            rating: rating);
        ls.add(product);
      }
      return ls;
    } else {
      throw Exception("Lỗi lấy dữ liệu. Chi tiết: ${response.statusCode}");
    }
  }
}
