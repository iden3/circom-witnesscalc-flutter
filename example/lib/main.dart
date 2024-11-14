import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:circom_witnesscalc/circom_witnesscalc.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _circomWitnesscalcPlugin = CircomWitnesscalc();

  String? _inputsUri;
  String? _inputs;
  String? _graphDataUri;
  Uint8List? _graphData;

  Uint8List? _witness;
  int _timestamp = 0;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _inputs = await rootBundle.loadString("assets/authV2_inputs.json");
      _graphData =
          (await rootBundle.load("assets/authV2.wcd")).buffer.asUint8List();
    });
  }

  @override
  Widget build(BuildContext context) {
    final customInputsUri = _inputsUri;
    final hasCustomInputsUri = customInputsUri != null;
    final customGraphDataUri = _graphDataUri;
    final hasCustomGraphUri = customGraphDataUri != null;

    final String result;
    if (_errorMessage.isNotEmpty) {
      result = "Error: $_errorMessage";
    } else if (_witness != null) {
      result = ("Witness generated in $_timestamp millis");
    } else {
      result = "Generate witness";
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              customInputsUri != null
                  ? "Custom inputs from $customInputsUri"
                  : "Default authV2 inputs selected",
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      allowMultiple: false,
                      allowedExtensions: ["json"],
                    );

                    final file = result?.files.first;
                    if (file == null) {
                      return;
                    }

                    setState(() {
                      _inputs = const Utf8Decoder().convert(file.bytes!);
                      _inputsUri = file.path ?? file.name;
                    });
                  },
                  child: const Text(
                    "Select inputs",
                  ),
                ),
                OutlinedButton(
                  onPressed: hasCustomInputsUri ? resetInputs : null,
                  child: const Text(
                    "Reset inputs",
                  ),
                ),
              ],
            ),
            Text(
              customGraphDataUri != null
                  ? "Custom graph data from $customGraphDataUri"
                  : "Default authV2 graph data selected",
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      allowMultiple: false,
                      allowedExtensions: ["wcd"],
                    );

                    final file = result?.files.first;
                    if (file == null) {
                      return;
                    }

                    setState(() {
                      _graphData = file.bytes;
                      _graphDataUri = file.path ?? file.name;
                    });
                  },
                  child: const Text(
                    "Select graph data",
                  ),
                ),
                OutlinedButton(
                  onPressed: hasCustomGraphUri ? resetGraphData : null,
                  child: const Text(
                    "Reset graph data",
                  ),
                ),
              ],
            ),
            Text(result),
            OutlinedButton(
              onPressed: onGenerate,
              child: const Text(
                "Generate",
              ),
            ),
            if (_witness != null)
              OutlinedButton(
                onPressed: onShare,
                child: const Text(
                  "Share",
                ),
              ),
          ],
        ),
      ),
    );
  }

  void resetInputs() {
    setState(() {
      _inputs = null;
      _inputsUri = null;
    });
  }

  void resetGraphData() {
    setState(() {
      _graphData = null;
      _graphDataUri = null;
    });
  }

  Future<void> onGenerate() async {
    _witness = null;
    if (_inputs == null || _graphData == null) {
      return;
    }

    final stopwatch = Stopwatch()..start();
    try {
      final witness = await _circomWitnesscalcPlugin.calculateWitness(
        inputs: _inputs!,
        graphData: _graphData!,
      );

      setState(() {
        _witness = witness;
        _timestamp = stopwatch.elapsedMilliseconds;
        _errorMessage = "";
      });
    } on PlatformException catch (e) {
      setState(() {
        _errorMessage = e.message ?? "Unknown error";
      });
    } finally {
      stopwatch.stop();
    }
  }

  void onShare() {
    if (_witness == null) {
      return;
    }

    Share.shareXFiles(
      [
        XFile.fromData(_witness!, name: "witness.wtns"),
      ],
      text: "Witness generated in $_timestamp millis",
    );
  }
}
