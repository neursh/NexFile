import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:path/path.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:mime/mime.dart';
import 'package:flutter/services.dart' show rootBundle;

class HttpService {
  late HttpServer server;
  late String explorer;

  String svgIcon(String fileEx) {
    fileEx = fileEx.toLowerCase();
    if ([
      "apng",
      "avif",
      "gif",
      "jpg",
      "jpeg",
      "jpe",
      "jif",
      "jfi",
      "jfif",
      "pjpeg",
      "pjp",
      "png",
      "svg",
      "svgz",
      "webp",
      "bmp",
      "dib",
      "ico",
      "cur",
      "tif",
      "tiff",
      "psd",
      "raw",
      "arw",
      "cr2",
      "nrw",
      "k25",
      ".heif",
      "heic",
      "ind",
      "indd",
      "indt",
      "jp2",
      "j2k",
      "jpf",
      "jpx",
      "jpm",
      "mj2"
    ].contains(fileEx)) {
      return "<svg height=\"24\" width=\"32\" fill=\"#FFFFFF\" viewBox=\"0 96 960 960\"><path d=\"M180 936q-24 0-42-18t-18-42V276q0-24 18-42t42-18h600q24 0 42 18t18 42v600q0 24-18 42t-42 18H180Zm0-60h600V276H180v600Zm56-97h489L578 583 446 754l-93-127-117 152Zm-56 97V276v600Z\"/></svg>";
    } else if (fileEx == "docx" || fileEx == "doc") {
      return "<svg height=\"24\" width=\"32\" fill=\"#FFFFFF\" viewBox=\"0 0 24 24\"><path d=\"M5 3C3.89 3 3 3.89 3 5V19C3 20.11 3.89 21 5 21H19C20.11 21 21 20.11 21 19V5C21 3.89 20.11 3 19 3H5M5 5H19V19H5V5M17.9 7L15.5 17H14L12 9.5L10 17H8.5L6.1 7H7.8L9.34 14.5L11.3 7H12.7L14.67 14.5L16.2 7H17.9Z\"/></svg>";
    } else if (fileEx == "pptx" || fileEx == "ppt") {
      return "<svg height=\"24\" width=\"32\" fill=\"#FFFFFF\" viewBox=\"0 0 24 24\"><path d=\"M5 3C3.89 3 3 3.89 3 5V19C3 20.11 3.89 21 5 21H19C20.11 21 21 20.11 21 19V5C21 3.89 20.11 3 19 3H5M5 5H19V19H5V5M15.1 7.88C14.45 7.29 13.83 7 12.3 7H8V17H9.8V13.4H12.3C13.8 13.4 14.46 13.12 15.1 12.58C15.74 12.03 16 11.25 16 10.23C16 9.26 15.75 8.5 15.1 7.88M13.6 11.5C13.28 11.81 12.9 12 12.22 12H9.8V8.4H12.1C12.76 8.4 13.27 8.65 13.6 9C13.93 9.35 14.1 9.72 14.1 10.24C14.1 10.8 13.92 11.19 13.6 11.5Z\" /></svg>";
    } else if (fileEx == "apk") {
      return "<svg height=\"24\" width=\"32\" fill=\"#FFFFFF\" viewBox=\"0 0 24 24\"><path d=\"M16.61 15.15C16.15 15.15 15.77 14.78 15.77 14.32S16.15 13.5 16.61 13.5H16.61C17.07 13.5 17.45 13.86 17.45 14.32C17.45 14.78 17.07 15.15 16.61 15.15M7.41 15.15C6.95 15.15 6.57 14.78 6.57 14.32C6.57 13.86 6.95 13.5 7.41 13.5H7.41C7.87 13.5 8.24 13.86 8.24 14.32C8.24 14.78 7.87 15.15 7.41 15.15M16.91 10.14L18.58 7.26C18.67 7.09 18.61 6.88 18.45 6.79C18.28 6.69 18.07 6.75 18 6.92L16.29 9.83C14.95 9.22 13.5 8.9 12 8.91C10.47 8.91 9 9.24 7.73 9.82L6.04 6.91C5.95 6.74 5.74 6.68 5.57 6.78C5.4 6.87 5.35 7.08 5.44 7.25L7.1 10.13C4.25 11.69 2.29 14.58 2 18H22C21.72 14.59 19.77 11.7 16.91 10.14H16.91Z\" /></svg>";
    } else if (fileEx == "pdf") {
      return "<svg height=\"24\" width=\"32\" fill=\"#FFFFFF\" viewBox=\"0 0 24 24\"><path d=\"M19 3H5C3.9 3 3 3.9 3 5V19C3 20.1 3.9 21 5 21H19C20.1 21 21 20.1 21 19V5C21 3.9 20.1 3 19 3M9.5 11.5C9.5 12.3 8.8 13 8 13H7V15H5.5V9H8C8.8 9 9.5 9.7 9.5 10.5V11.5M14.5 13.5C14.5 14.3 13.8 15 13 15H10.5V9H13C13.8 9 14.5 9.7 14.5 10.5V13.5M18.5 10.5H17V11.5H18.5V13H17V15H15.5V9H18.5V10.5M12 10.5H13V13.5H12V10.5M7 10.5H8V11.5H7V10.5Z\" /></svg>";
    } else if ([
      "mkv",
      "webm",
      "mpg",
      "mp2",
      "mpeg",
      "mpe",
      "mpv",
      "ogg",
      "mp4",
      "m4p",
      "m4v",
      "avi",
      "wmv",
      "mov",
      "qt",
      "flv",
      "swf"
    ].contains(fileEx)) {
      return "<svg height=\"24\" width=\"32\" fill=\"#FFFFFF\" viewBox=\"0 0 24 24\"><title>video-outline</title><path d=\"M15,8V16H5V8H15M16,6H4A1,1 0 0,0 3,7V17A1,1 0 0,0 4,18H16A1,1 0 0,0 17,17V13.5L21,17.5V6.5L17,10.5V7A1,1 0 0,0 16,6Z\" /></svg>";
    } else if (["zip", "rar", "gzip", "7z"].contains(fileEx)) {
      return "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><title>zip-box-outline</title><path d=\"M12 17V15H14V17H12M14 13V11H12V13H14M14 9V7H12V9H14M10 11H12V9H10V11M10 15H12V13H10V15M21 5V19C21 20.1 20.1 21 19 21H5C3.9 21 3 20.1 3 19V5C3 3.9 3.9 3 5 3H19C20.1 3 21 3.9 21 5M19 5H12V7H10V5H5V19H19V5Z\" /></svg>";
    }
    return "<svg height=\"24\" width=\"32\" fill=\"#FFFFFF\" viewBox=\"0 96 960 960\"><path d=\"M220 976q-24 0-42-18t-18-42V236q0-24 18-42t42-18h361l219 219v521q0 24-18 42t-42 18H220Zm331-554V236H220v680h520V422H551ZM220 236v186-186 680-680Z\"/></svg>";
  }

  String contentDisplay(String name, bool isFile) {
    String shortenName = name;
    if (name.length > 17) {
      shortenName = '${name.substring(0, 10)}...${name.substring(name.length - 10, name.length)}';
    }

    return "<a href=\"$name${isFile ? "" : "/"}\"><div class=\"card ${isFile ? "border-primary" : "border-success"}\" style=\"width: 15rem;\"><div class=\"card-body\" style=\"display: flex; gap: 5px;\">${!isFile ? "<svg height=\"24\" width=\"32\" fill=\"#FFFFFF\" viewBox=\"0 96 960 960\"><path d=\"M141 896q-24 0-42-18.5T81 836V316q0-23 18-41.5t42-18.5h280l60 60h340q23 0 41.5 18.5T881 376v460q0 23-18.5 41.5T821 896H141Zm0-580v520h680V376H456l-60-60H141Zm0 0v520-520Z\"/></svg>" : svgIcon(name.split(".").last)}<p class=\"card-text\">$shortenName</p></div></div></a>";
  }

  Future<Response> serverServe(Request request) async {
    String rawRequest = request.url.toFilePath();
    String destination = "/storage/emulated/0/$rawRequest";
    File target = File(destination);
    FileSystemEntityType type = (await target.stat()).type;

    if (type == FileSystemEntityType.file) {
      String contentLength = (await target.length()).toString();
      String targetType = lookupMimeType(destination) ?? "";

      if (request.headers.keys.contains("range")) {
        var points = request.headers["range"]!.substring(6).split("-");
        int starting = int.tryParse(points[0]) ?? 0;
        int ending = int.tryParse(points[1]) ?? int.parse(contentLength) - 1;
        return Response(206, body: target.openRead(starting, ending), headers: {
          "Content-Type": targetType,
          "Content-Length": contentLength,
          "Accept-Ranges": "bytes",
          "Content-Range": "bytes $starting-$ending/$contentLength"
        });
      }
      return Response(200,
          body: target.openRead(),
          headers: {"Content-Type": targetType, "Content-Length": contentLength});
    }
    if (type == FileSystemEntityType.directory) {
      List<String> folders = ["Home"] + rawRequest.split("/");
      return Response(200,
          body: explorer
              .replaceAll(r"$WORKING-DIRECTORY$", "/$rawRequest")
              .replaceAll(
                  r"$PATH-CRUMB$",
                  [
                    for (int i = 0; i < folders.length; i++)
                      "<li class=\"breadcrumb-item\"><a href=\"${[
                        for (int c = folders.length - 2; c > i; c--) "../"
                      ].join("")}\">${folders[i]}</a></li>"
                  ].join("\n"))
              .replaceAll(
                  r"$DIRECTORY-CONTENTS$",
                  [
                    for (var obj in (await Directory(target.path).list().toList()))
                      contentDisplay(
                          basename(obj.path), (await obj.stat()).type == FileSystemEntityType.file),
                  ].join("\n")),
          headers: {"Content-Type": "text/html"});
    }
    return Response(404, body: "Not found.");
  }

  startService(String hostIP, port) async {
    explorer = await rootBundle.loadString("interface/index_compiled.html");
    var handler = const Pipeline().addMiddleware(logRequests()).addHandler(serverServe);
    server = await shelf_io.serve(handler, hostIP, port, poweredByHeader: null);
  }

  stopService() async {
    server.close(force: true);
  }
}
