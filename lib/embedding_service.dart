import 'package:google_generative_ai/google_generative_ai.dart';

final geminiModel = GenerativeModel(
  model: 'embedding-001',
  apiKey: 'AIzaSyB25GjK6VdU5qPGtTXEzQSUgTPCElyX2Wk',
);

Future<List<double>> generateEmbedding(String text) async {
  final content = Content.text(text);
  final response = await geminiModel.embedContent(content);
  final values = response.embedding.values;

  return values.map((e) => (e as num).toDouble()).toList();
}
