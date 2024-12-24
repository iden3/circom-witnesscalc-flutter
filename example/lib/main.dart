import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:circom_witnesscalc/circom_witnesscalc.dart';
import 'package:flutter_rapidsnark/flutter_rapidsnark.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

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

  String? _inputsPath;
  String? _graphWCDPath;
  String? _zkeyFilePath;

  String? _defaultInputsPath;
  String? _defaultGraphWCDPath;
  String? _defaultZkeyFilePath;

  Uint8List? _witness;
  int _witnessTimestamp = 0;
  int _proofGenerationTimestamp = 0;
  String? _proof;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await copyAssetToDocumentsDirectory('assets/authV2_inputs.json');
      await copyAssetToDocumentsDirectory('assets/authV2.wcd');
      await copyAssetToDocumentsDirectory('assets/authV2.zkey');

      final directory = await getApplicationDocumentsDirectory();
      _defaultInputsPath = '${directory.path}/authV2_inputs.json';
      _defaultGraphWCDPath = '${directory.path}/authV2.wcd';
      _defaultZkeyFilePath = '${directory.path}/authV2.zkey';

      resetData();
    });
  }

  void resetData() {
    setState(() {
      _inputsPath = _defaultInputsPath;
      _graphWCDPath = _defaultGraphWCDPath;
      _zkeyFilePath = _defaultZkeyFilePath;
      resetOutputs();
    });
  }

  void resetOutputs() {
    _witness = null;
    _witnessTimestamp = 0;
    _proofGenerationTimestamp = 0;
    _proof = null;
    _errorMessage = "";
  }

  Future<void> copyAssetToDocumentsDirectory(String asset) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = asset
        .split('/')
        .last;
    final file = File('${directory.path}/$fileName');

    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String witnessResult;
    if (_errorMessage.isNotEmpty) {
      witnessResult = "Error: $_errorMessage";
    } else if (_witness != null) {
      witnessResult = ("Witness generated in $_witnessTimestamp millis");
    } else {
      witnessResult = "Generate witness";
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: resetData,
                  child: const Text("Reset all inputs"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    _defaultInputsPath != _inputsPath
                        ? "Inputs json: ${basename(_inputsPath!)}"
                        : "Default authV2 inputs selected",
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ["json"],
                      );

                      final file = result?.files.first;
                      if (file != null && file.path != null) {
                        setState(() {
                          _inputsPath = file.path!;
                          resetOutputs();
                        });
                      }
                    },
                    icon: const Icon(Icons.file_open),
                    label: const Text("Select"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    _defaultGraphWCDPath != _graphWCDPath
                        ? "Selected .wcd graph file: ${basename(_graphWCDPath!)}"
                        : "Default authV2.wcd graph selected",
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(type: FileType.any);

                      final file = result?.files.first;
                      if (file?.path != null) {
                        final fileBytes = await File(file!.path!).readAsBytes();
                        setState(() {
                          _graphWCDPath = file.path!;
                          resetOutputs();
                        });
                      }
                    },
                    icon: const Icon(Icons.file_open),
                    label: const Text("Select"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    _defaultZkeyFilePath != _zkeyFilePath
                        ? "Selected .zkey File path: ${basename(_zkeyFilePath!)}"
                        : "Default authV2 graph data selected",
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(type: FileType.any);

                      final file = result?.files.first;
                      if (file?.path != null) {
                        setState(() {
                          _zkeyFilePath = file!.path!;
                          resetOutputs();
                        });
                      }
                    },
                    icon: const Icon(Icons.file_open),
                    label: const Text("Select"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(witnessResult, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onGenerateWitness,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Generate witness"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (_witness != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onShare,
                    child: const Text("Share witness"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onGenerateProof,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Generate proof"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
                if (_proof != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onShareProof,
                    child: const Text("Share proof"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Proof generated in $_proofGenerationTimestamp millis", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Text(_proof!, style: const TextStyle(fontSize: 16)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Generate the witness
  Future<void> onGenerateWitness() async {

    final stopwatch = Stopwatch();
    try {

      if (_defaultInputsPath == null || _graphWCDPath == null) {
        return;
      }

      final file = File(_inputsPath!);
      final inputs = await file.readAsString();

      final fileWCD = File(_graphWCDPath!);
      final graphData = await fileWCD.readAsBytes();

      stopwatch.start();
      final witness = await _circomWitnesscalcPlugin.calculateWitness(
        inputs: inputs,
        graphData: graphData,
      );

      setState(() {
        _witness = witness;
        _witnessTimestamp = stopwatch.elapsedMilliseconds;
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

  // Generate the proof
  Future<void> onGenerateProof() async {
    if (_witness == null) {
      return;
    }

    final stopwatch = Stopwatch();
    try {
      stopwatch.start();
      final zkProof = await Rapidsnark().groth16ProveWithZKeyFilePath(witness: _witness!, zkeyPath: _zkeyFilePath!);
      _proofGenerationTimestamp = stopwatch.elapsedMilliseconds;


      //console log the proof and public signals
      final proofData = {
        'proof': zkProof.proof,
        'pubSignals': zkProof.publicSignals,
      };

      // Convert the map to a JSON string
      final proofJson = jsonEncode(proofData);

      setState(() {
        _proof = proofJson;


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
      text: "Witness generated in $_witnessTimestamp millis",
    );
  }

  void onShareProof() {
    if (_proof == null) {
      return;
    }

    Share.shareXFiles(
      [
        XFile.fromData(Uint8List.fromList(utf8.encode(_proof!)), name: "proof.json"),
      ],
      text: "Proof generated in $_proofGenerationTimestamp millis",
    );
  }
}