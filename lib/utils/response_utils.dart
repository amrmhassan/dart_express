import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart';

class ResponseUtils {
  // void writeFile(HttpRequest req, String filePath) {
  //   File file = File(filePath);
  //   // check if file exists
  //   if (!file.existsSync()) {
  //     throw Exception('File $filePath doesn\'t exist');
  //   }
  //   String fileName =
  //       file.path.split('/').last; // Extract the filename from the file path
  //   String? mime = lookupMimeType(filePath);

  //   req.response.statusCode = HttpStatus.ok;
  //   req.response.headers
  //     ..contentType = ContentType.parse(mime ?? 'application/octet-stream')
  //     ..contentLength = file.lengthSync()
  //     ..add('Content-Disposition',
  //         'attachment; filename=$fileName'); // Set the Content-Disposition header

  //   file.openRead().pipe(req.response);
  // }

  // void streamFile(HttpRequest req, String filePath) {
  //   File file = File(filePath);
  //   // check if file exists
  //   if (!file.existsSync()) {
  //     throw Exception('file $filePath doesn\'t exist');
  //   }
  //   int length = file.lengthSync();
  //   String range = req.headers.value('range') ?? 'bytes=0-';
  //   List<String> parts = range.split('=');
  //   List<String> positions = parts[1].split('-');
  //   int start = int.parse(positions[0]);
  //   int end = positions.length < 2 || int.tryParse(positions[1]) == null
  //       ? length
  //       : int.parse(positions[1]);
  //   String? mime = lookupMimeType(filePath);

  //   req.response.statusCode = HttpStatus.partialContent;
  //   req.response.headers
  //     ..contentType = ContentType.parse(mime ?? 'application/octet-stream')
  //     ..contentLength = end - start
  //     ..add('Accept-Ranges', 'bytes')
  //     ..add('Content-Range', 'bytes $start-$end/$length')
  //     ..add('Content-Disposition',
  //         'attachment; filename=${basename(file.path)}'); // Set the Content-Disposition header

  //   file.openRead(start, end).pipe(req.response);
  // }

  void sendChunkedFile(HttpRequest req, String filePath) {
    File file = File(filePath);
    // check if file exists
    if (!file.existsSync()) {
      throw Exception('File $filePath doesn\'t exist');
    }
    String fileName =
        file.path.split('/').last; // Extract the filename from the file path
    String? mime = lookupMimeType(filePath);

    req.response.statusCode = HttpStatus.ok;
    req.response.headers
      ..contentType = ContentType.parse(mime ?? 'application/octet-stream')
      ..add('Content-Disposition',
          'attachment; filename=$fileName') // Set the Content-Disposition header
      ..add('Accept-Ranges', 'bytes');

    int fileLength = file.lengthSync();
    int start = 0;
    int end = fileLength - 1;

    String? range = req.headers.value('range');
    if (range != null) {
      List<String> parts = range.split('=');
      List<String> positions = parts[1].split('-');
      start = int.parse(positions[0]);
      end = positions.length < 2 || int.tryParse(positions[1]) == null
          ? fileLength - 1
          : int.parse(positions[1]);
      req.response.statusCode = HttpStatus.partialContent;
      req.response.headers
        ..contentLength = end - start + 1
        ..add('Content-Range', 'bytes $start-$end/$fileLength');
    } else {
      req.response.headers.contentLength = fileLength;
    }

    RandomAccessFile raf = file.openSync();
    raf.setPositionSync(start);
    Stream<List<int>> fileStream = Stream.value(raf.readSync(end - start + 1));
    req.response
        .addStream(fileStream
            .handleError((e) => throw Exception('Error reading file: $e')))
        .then((_) {
      raf.closeSync();
      req.response.close();
    });
  }

  void streamMedia(HttpRequest req, String filePath) {
    File file = File(filePath);
    // check if file exists
    if (!file.existsSync()) {
      throw Exception('File $filePath doesn\'t exist');
    }

    String? mime = lookupMimeType(filePath);

    req.response.statusCode = HttpStatus.partialContent;
    req.response.headers.contentType =
        ContentType.parse(mime ?? 'application/octet-stream');
    req.response.headers.add('Accept-Ranges', 'bytes');

    RandomAccessFile raf = file.openSync();

    int fileLength = file.lengthSync();
    int start = 0;
    int end = fileLength - 1;

    String? range = req.headers.value('range');
    if (range != null) {
      // Parse the range header
      List<String> parts = range.split('=');
      List<String> positions = parts[1].split('-');
      start = int.parse(positions[0]);
      end = positions.length < 2 || int.tryParse(positions[1]) == null
          ? fileLength - 1
          : int.parse(positions[1]);
      final chunkSize = end - start + 1;

      // Set the Content-Range header
      req.response.headers
          .add('Content-Range', 'bytes $start-$end/$fileLength');
      req.response.headers.contentLength = chunkSize;

      // Seek to the requested position in the file
      raf.setPositionSync(start);

      // Create a stream for the requested chunk of data
      final fileStream = Stream.value(raf.readSync(chunkSize));

      req.response.addStream(fileStream).then((_) {
        raf.closeSync();
        req.response.close();
      });
    } else {
      // If no range is specified, stream the entire file
      req.response.headers.contentLength = fileLength;

      final fileStream = Stream.value(raf.readSync(fileLength));

      req.response.addStream(fileStream).then((_) {
        raf.closeSync();
        req.response.close();
      });
    }
  }

  void streamV2(HttpRequest req, String audioPath) {
    File file = File(audioPath);
    int length = file.lengthSync();

    // this formate 'bytes=0-' means that i want the bytes from the 0 to the end
    // so the end here means the end of the file
    // if it was 'bytes=0-1000' this means that i need the bytes from 0 to 1000
    String range = req.headers.value('range') ?? 'bytes=0-';
    List<String> parts = range.split('=');
    List<String> positions = parts[1].split('-');
    int start = int.parse(positions[0]);
    int end = positions.length < 2 || int.tryParse(positions[1]) == null
        ? length
        : int.parse(positions[1]);
    String? mime = lookupMimeType(audioPath);
    // print('Needed bytes from $start to $end');

    req.response.statusCode = HttpStatus.partialContent;
    req.response.headers
      ..contentType = ContentType.parse(mime ?? 'audio/mpeg')
      ..contentLength = end - start
      ..add('Accept-Ranges', 'bytes')
      ..add('Content-Range', 'bytes $start-$end/$length');
    file.openRead(start, end).pipe(req.response);
  }
}
