import 'package:flutter/material.dart';
import 'package:translation_app/db/db_helper.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  List allFavs = [];

  void getFavs() async {
    final dbHelper = FavDbHelper();

    var allFavsFromDb = await dbHelper.getData();
    print("allFavsFromDb: $allFavsFromDb");

    setState(() {
      allFavs = allFavsFromDb;
    });
  }

  void deleteRecord(int id) async {
    final dbHelper = FavDbHelper();

    await dbHelper.deleteRecord(id);

    getFavs();
  }

  @override
  void initState() {
    super.initState();

    // Add your initialization code here
    getFavs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Translator"),
        ),
        body: SafeArea(
            child: Center(
                child: allFavs.isEmpty
                    ? const Text("No favorites yet")
                    : SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: ListView(
                          children: allFavs
                              .map((e) => Column(children: [
                                    Card(
                                        child: ListTile(
                                            title: SelectableText(e["text"]),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () => deleteRecord(e["id"]),
                                            ),
                                            subtitle: SelectableText(e["translation"]))),
                                    const Divider()
                                  ]))
                              .toList(),
                        )))));
  }
}
