import 'package:custom_shelf/http_method.dart';
import 'package:custom_shelf/routing_entities.dart';

abstract class RequestProcessor {
  List<Processor> processors(String path, HttpMethod method);
}
