import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doctor_ki_bole/l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final data = await db.DBService.getAllResults();
    setState(() {
      _results = data;
      _loading = false;
    });
  }

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.delete),
        content: Text(loc.deleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.onErrorContainer,
            ),
            child: Text(loc.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await db.DBService.deleteResult(id);
      _loadResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(loc.savedResults)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? Center(
                  child: Text(
                    loc.noSavedResults,
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadResults,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final r = _results[index];
                      final formattedDate = DateFormat('yyyy-MM-dd HH:mm')
                          .format(r.timestamp.toLocal());

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: colorScheme.surfaceVariant,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
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
                                      backgroundColor: r.type == 'report'
                                          ? colorScheme.primary
                                          : colorScheme.secondary,
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: colorScheme.error),
                                      tooltip: loc.delete,
                                      onPressed: () => _confirmDelete(context, r.id!),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                _buildScrollableText("📥 ${r.input}", textTheme.bodyMedium),
                                const SizedBox(height: 6),
                                _buildScrollableText("💡 ${r.result}", textTheme.bodySmall,
                                    maxHeight: 150),
                                const SizedBox(height: 6),
                                Text(
                                  "⏰ $formattedDate",
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildScrollableText(String text, TextStyle? style, {double maxHeight = 80}) {
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: const EdgeInsets.only(right: 4),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Text(text, style: style),
        ),
      ),
    );
  }
}
