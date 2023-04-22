import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'http_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      theme: ThemeData(colorSchemeSeed: Colors.brown, useMaterial3: true),
      darkTheme:
          ThemeData(colorSchemeSeed: Colors.brown, useMaterial3: true, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const MainArea()));
}

ValueNotifier<bool> serverStarted = ValueNotifier(false);
ValueNotifier<bool> keepAlive = ValueNotifier(false);
ValueNotifier<bool> requireAccess = ValueNotifier(true);
ValueNotifier<bool> modernHTML = ValueNotifier(false);

class MainArea extends StatefulWidget {
  const MainArea({super.key});

  @override
  State<MainArea> createState() => _MainArea();
}

class _MainArea extends State<MainArea> {
  HttpService svObj = HttpService();
  ValueNotifier<int> port = ValueNotifier<int>(8080);
  bool isPortCustomized = false;
  ValueNotifier<String> hostedOn = ValueNotifier<String>("");

  ValueNotifier<bool> settingsExpanded = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("NexFile"), centerTitle: true),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
                child: Column(children: [
              OptionBuilder(
                  title: "Máy chủ",
                  description: "Bắt đầu một máy chủ để chia sẻ tệp trong mạng cục bộ.",
                  observe: serverStarted,
                  onChanged: (_) async {
                    if ((await (Connectivity().checkConnectivity())) == ConnectivityResult.wifi) {
                      if ((await Permission.manageExternalStorage.request()).isGranted ||
                          (await Permission.storage.request()).isGranted) {
                        String hostIP = (await NetworkInfo().getWifiIP())!;
                        !serverStarted.value
                            ? await svObj.startService(hostIP, port: port.value)
                            : await svObj.stopService();
                        !serverStarted.value
                            ? hostedOn.value = "http://$hostIP:${port.value}"
                            : hostedOn.value = "";
                        serverStarted.value = !serverStarted.value;
                      } else {
                        Fluttertoast.showToast(
                            msg: "Quyền truy cập tệp không được cấp!",
                            toastLength: Toast.LENGTH_LONG);
                      }
                    } else {
                      Fluttertoast.showToast(
                          msg: "Chỉ sử dụng mạng wifi!", toastLength: Toast.LENGTH_LONG);
                    }
                  },
                  thumbIcon: MaterialStateProperty.resolveWith<Icon?>((Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return const Icon(Icons.play_arrow);
                    }
                    return const Icon(Icons.stop);
                  })),
              OptionBuilder(
                  title: "Giữ máy bật",
                  description: "Tắt chế độ đặt máy vào chế độ ngủ để máy chủ luôn được bật.",
                  observe: keepAlive,
                  onChanged: (_) async {
                    !keepAlive.value ? Wakelock.enable() : Wakelock.disable();
                    keepAlive.value = await Wakelock.enabled;
                  },
                  thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                      (Set<MaterialState> states) => const Icon(Icons.bolt))),
              Card(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                      child: ListTile(
                          title:
                              Text("Cổng máy chủ", style: Theme.of(context).textTheme.titleLarge),
                          subtitle: AnimatedBuilder(
                              animation: port,
                              builder: (context, child) => Wrap(
                                      alignment: WrapAlignment.center,
                                      runAlignment: WrapAlignment.center,
                                      spacing: 7,
                                      runSpacing: 7,
                                      children: [
                                        InputChip(
                                            label: const Text("8080"),
                                            onSelected: (_) async {
                                              port.value = 8080;
                                              isPortCustomized = false;
                                            },
                                            selected: port.value == 8080),
                                        ChoiceChip(
                                            label: Text(
                                                isPortCustomized ? "${port.value}" : "Tùy chỉnh"),
                                            onSelected: (_) => customPort(),
                                            selected: port.value != 8080)
                                      ]))))),
              Card(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                      child: ListTile(
                          title: Text("Thông tin", style: Theme.of(context).textTheme.titleLarge),
                          subtitle: AnimatedBuilder(
                              animation: hostedOn,
                              builder: (context, child) => Column(children: [
                                    Text(hostedOn.value == ""
                                        ? "Đang chờ..."
                                        : "Máy chủ đã được mở tại: ${hostedOn.value}"),
                                    const SizedBox(height: 10),
                                    hostedOn.value != ""
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: QrImage(
                                              backgroundColor: Colors.white,
                                              data: hostedOn.value,
                                              version: QrVersions.auto,
                                              size: 200.0,
                                            ))
                                        : const SizedBox(),
                                  ])))))
            ]))));
  }

  void customPort() {
    ValueNotifier<String> cPort = ValueNotifier<String>("");
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (n) => cPort.value = n,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Cổng số", hintText: "1024 - 65536"),
              )
            ],
          ),
        ),
        actions: [
          AnimatedBuilder(
              animation: cPort,
              builder: (context, child) => TextButton(
                  onPressed: cPort.value != "" &&
                          1024 <= int.parse(cPort.value) &&
                          int.parse(cPort.value) <= 65536
                      ? () {
                          isPortCustomized = true;
                          port.value = int.parse(cPort.value);
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text("Xác nhận"))),
        ],
      ),
    );
  }
}

class OptionBuilder extends StatelessWidget {
  final String title, description;
  final void Function(bool)? onChanged;
  final ValueNotifier observe;
  final MaterialStateProperty<Icon?>? thumbIcon;
  const OptionBuilder(
      {super.key,
      required this.title,
      required this.description,
      this.onChanged,
      required this.observe,
      this.thumbIcon});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(children: [
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          child: Row(children: [
            SizedBox(
                width: MediaQuery.of(context).size.width - 104,
                child: ListTile(
                    title: Text(title, style: Theme.of(context).textTheme.titleLarge),
                    subtitle: Text(description))),
            AnimatedBuilder(
                animation: observe,
                builder: (context, child) {
                  return Switch(
                      thumbIcon: thumbIcon,
                      splashRadius: 0,
                      value: observe.value,
                      onChanged: onChanged);
                })
          ])),
      AnimatedBuilder(
          animation: observe,
          builder: (context, child) {
            return SizedBox(
                height: 10,
                child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                    child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                        tween: Tween<double>(begin: 0, end: observe.value ? 1 : 0),
                        builder: (context, value, _) => LinearProgressIndicator(value: value))));
          })
    ]));
  }
}
