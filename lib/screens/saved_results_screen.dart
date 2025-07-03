import 'package:flutter/material.dart';
import '../services/db_service.dart' as db;
import '../models/saved_result.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SavedResultsScreen extends StatefulWidget {
  const SavedResultsScreen({super.key});

  @override
  State<SavedResultsScreen> createState() => _SavedResultsScreenState();
}

class _SavedResultsScreenState extends State<SavedResultsScreen> {
  List<SavedResult> _results = [];

  Future<void> _loadResults() async {
    final data = await db.DBService.getAllResults();
    setState(() {
      _results = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.savedResults)),
      body: _results.isEmpty
          ? Center(child: Text(loc.noSavedResults))
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final r = _results[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(r.type.toUpperCase()),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📝 ${r.input}"),
                        const SizedBox(height: 5),
                        Text("📖 ${r.result}"),
                        Text("📅 ${r.timestamp.toLocal()}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: loc.delete,
                      onPressed: () async {
                        await db.DBService.deleteResult(r.id!);
                        _loadResults();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
