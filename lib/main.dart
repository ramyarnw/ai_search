import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'objectbox.g.dart';
import 'text_item.dart';
import 'embedding_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final store = await openStore(directory: dir.path);
  runApp(MyApp(store));
}

class MyApp extends StatelessWidget {
  final Store store;

  const MyApp(this.store, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ObjectBox + Gemini AI',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: SimilarityHome(store),
    );
  }
}

class SimilarityHome extends StatefulWidget {
  final Store store;

  const SimilarityHome(this.store, {super.key});

  @override
  State<SimilarityHome> createState() => _SimilarityHomeState();
}

class _SimilarityHomeState extends State<SimilarityHome> {
  final TextEditingController _controller = TextEditingController();
  late final Box<TextItem> box;
  List<TextItem> results = [];

  @override
  void initState() {
    super.initState();
    box = widget.store.box<TextItem>();
  }

  Future<void> _addText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final embedding = await generateEmbedding(text);
    final item = TextItem(text: text, embeddingJson: embedding.join(','));
    box.put(item);
    _controller.clear();
    setState(() {});
  }

  Future<void> _searchSimilar() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    final queryVec = await generateEmbedding(query);
    final all = box.getAll();

    all.sort(
      (a, b) => cosineSimilarity(
        b.embedding,
        queryVec,
      ).compareTo(cosineSimilarity(a.embedding, queryVec)),
    );

    setState(() {
      results = all.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini AI + ObjectBox')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Enter text'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(onPressed: _addText, child: const Text("Add")),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _searchSimilar,
                  child: const Text("Search Similar"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Top Matches:"),
            const SizedBox(height: 8),
            ...results.map((e) => ListTile(title: Text(e.text))),

          ],
        ),
      ),
    );
  }
}

double cosineSimilarity(List<double> a, List<double> b) {
  double dot = 0, normA = 0, normB = 0;
  for (int i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  return dot / (sqrt(normA) * sqrt(normB));
}
