import 'package:custom_shelf/http_method.dart';
import 'package:custom_shelf/pipeline.dart';
import 'package:custom_shelf/request_processor.dart';
import 'package:custom_shelf/routing_entities.dart';

class Cascade implements RequestProcessor {
  List<Pipeline> pipeLines = [];

  Cascade add(Pipeline pipeline) {
    pipeLines.add(pipeline);
    return this;
  }

  @override
  List<RoutingEntity> processors(String path, HttpMethod method) {
    List<RoutingEntity> prs = [];
    for (var pipeLine in pipeLines) {
      List<RoutingEntity> pipeLineProcessors =
          pipeLine.processors(path, method);
      if (pipeLineProcessors.isNotEmpty) {
        prs.addAll(pipeLineProcessors);
      }
    }
    return prs;
  }
}
