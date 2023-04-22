import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:path/path.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:mime/mime.dart';

class HttpService {
  late HttpServer server;

  Future<Response> serverServe(Request request) async {
    String destination = "/storage/emulated/0/${request.url}";

    File target = File(destination);
    String contentLength = (await target.length()).toString();
    String targetType = lookupMimeType(destination) ?? "";
    String targetName = basename(target.path);

    if (request.headers.keys.contains("range")) {
      var points = request.headers["range"]!.substring(6).split("-");
      int starting = int.tryParse(points[0]) ?? 0;
      int ending = int.tryParse(points[1]) ?? int.parse(contentLength) - 1;
      return Response(206, body: target.openRead(starting, ending), headers: {
        "Content-Type": targetType,
        "Content-Length": contentLength,
        "Accept-Ranges": "bytes",
        "Content-Range": "bytes $starting-$ending/$contentLength",
        "Content-Disposition": "inline; filename=$targetName"
      });
    }
    return Response(200, body: target.openRead(), headers: {
      "Content-Type": targetType,
      "Content-Length": contentLength,
      "Content-Disposition": "inline; filename=$targetName"
    });
  }

  startService(String hostIP, {int port = 8080}) async {
    var handler = const Pipeline().addMiddleware(logRequests()).addHandler(serverServe);
    server = await shelf_io.serve(handler, hostIP, port, poweredByHeader: null);
  }

  stopService() async {
    server.close(force: true);
  }
}
