import 'package:doctor_ki_bole/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../services/db_service.dart' as db;
import '../models/saved_result.dart';

class SavedResultsScreen extends StatefulWidget {
  const SavedResultsScreen({super.key});

  @override
  State<SavedResultsScreen> createState() => _SavedResultsScreenState();
}

class _SavedResultsScreenState extends State<SavedResultsScreen> {
  List<SavedResult> _results = [];
  bool _loading = true;

  Future<void> _loadResults() async {
    final data = await db.DBService.getAllResults();
    setState(() {
      _results = data;
      _loading = false;
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? Center(child: Text(loc.noSavedResults))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final r = _results[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Chip(
                                  label: Text(
                                    r.type == 'report' ? loc.analyzeReport : loc.symptomChecker,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: r.type == 'report' ? Colors.teal : Colors.blue,
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: loc.delete,
                                  onPressed: () async {
                                    await db.DBService.deleteResult(r.id!);
                                    _loadResults();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "📥 ${r.input}",
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              softWrap: true,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 150),
                              padding: const EdgeInsets.only(right: 4),
                              child: Scrollbar(
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  child: Text(
                                    "💡 ${r.result}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "⏰ ${r.timestamp.toLocal()}",
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
