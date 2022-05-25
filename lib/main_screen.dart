import 'dart:convert';

import 'package:flutter/material.dart';
//import 'package:flutter_model_and_networking/data_model.dart';
import 'package:http/http.dart' as http;

import 'data_model.dart';
import 'detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<DataModel> items = [];
  bool hasMore = true;
  int page = 1;
  bool isLoading = false;

  final scrollController = ScrollController();

  Future fetch() async {
    if (isLoading) return;

    isLoading = true;

    final url = Uri.parse(
        'https://script.google.com/macros/s/AKfycbxSW2d_VuQzc-GoYTy0WU4g8zoKk6-OwT0z_xu3NEWb9sBquieXheDSJDcbRSf8K8db/exec?page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var result = json.decode(response.body);

      var data = result['data'] as List;

      final newItems = data.map((json) => DataModel.fromJson(json)).toList();

      setState(() {
        page++;

        isLoading = false;

        if (newItems.isEmpty) {
          hasMore = false;
        }

        items.addAll(newItems);
      });
    }
  }

  Future refresh() async {
    setState(() {
      items.clear();
      hasMore = true;
      page = 1;
      isLoading = false;
    });

    fetch();
  }

  @override
  void initState() {
    super.initState();

    fetch();

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        fetch();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Judul Halaman'),
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: RefreshIndicator(
          onRefresh: refresh,
          child: ListView.builder(
            controller: scrollController,
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index < items.length) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(item.imageLocationUrl),
                    title: Text(item.name),
                    subtitle: Text(item.phoneNumber),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: ((context) => DetailScreen(item: item)),
                        ),
                      );
                    },
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: hasMore
                    ? const Center(child: CircularProgressIndicator())
                    : const Center(child: Text('No more data to load')),
              );
            },
          ),
        ),
      ),
    );
  }
}
