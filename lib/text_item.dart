
import 'package:objectbox/objectbox.dart';

@Entity()
class TextItem {
  int id = 0;
  String text;
  String embeddingJson;

  TextItem({required this.text, required this.embeddingJson});

  List<double> get embedding => embeddingJson.split(',').map(double.parse).toList();
}
