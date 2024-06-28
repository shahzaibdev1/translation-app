import 'package:flutter/material.dart';
import 'package:translation_app/db/db_helper.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List allHistory = [];

  void getHistory() async {
    final dbHelper = HistoryDbHelper();

    var allHistoryFromDb = await dbHelper.getData();
    print("allHistoryFromDb: $allHistoryFromDb");

    setState(() {
      allHistory = allHistoryFromDb;
    });
  }

  void deleteRecord(int id) async {
    final dbHelper = HistoryDbHelper();

    await dbHelper.deleteRecord(id);

    getHistory();
  }

  @override
  void initState() {
    super.initState();

    // Add your initialization code here
    getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(
                tabs: [
                  Tab(text: "Translation"),
                  Tab(text: "Conversation"),
                  // Tab(icon: Icon(Icons.directions_transit)),
                  // Tab(icon: Icon(Icons.directions_bike)),
                ],
              ),
              title: const Text('History'),
            ),
            body: TabBarView(
              children: [
                // Translation tab
                Center(
                    child: allHistory.isEmpty
                        ? const Text("No history yet")
                        : SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: ListView.separated(
                              itemCount: allHistory
                                  .where((element) => element["type"] == "Translate")
                                  .length,
                              itemBuilder: (context, index) {
                                final e = allHistory
                                    .where((element) => element["type"] == "Translate")
                                    .toList()[index];
                                return Card(
                                  elevation: 0,
                                  child: ListTile(
                                    title: SelectableText(e["text"]),
                                    subtitle: SelectableText(e["translation"]),
                                    // Uncomment and use the trailing icon if needed
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => deleteRecord(e["id"]),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider(
                                  color: Colors.grey[200],
                                  thickness: 1.0,
                                );
                              },
                            ))),
                // Converstion tab
                Center(
                    child: allHistory.isEmpty
                        ? const Text("No history yet")
                        : SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: ListView.separated(
                              itemCount: allHistory
                                  .where((element) => element["type"] == "Conversation")
                                  .length,
                              itemBuilder: (context, index) {
                                final e = allHistory
                                    .where((element) => element["type"] == "Conversation")
                                    .toList()[index];
                                return Card(
                                  elevation: 0,
                                  child: ListTile(
                                    title: SelectableText(e["text"]),
                                    subtitle: SelectableText(e["translation"]),
                                    // Uncomment and use the trailing icon if needed
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => deleteRecord(e["id"]),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider(
                                  color: Colors.grey[200],
                                  thickness: 1.0,
                                );
                              },
                            )))
              ],
            )));
  }
}
