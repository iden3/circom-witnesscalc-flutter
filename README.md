# circom_witnesscalc

---

This library is Flutter wrapper for the [circom-witnesscalc](https://github.com/iden3/circom-witnesscalc).
It is used to calculate witness files for zero knowledge proofs, written in Rust.

## Platform Support

**iOS**: Compatible with any iOS device with 64 bit architecture.

**macOS**: Compatible with any macOS device with arm64 bit architecture.

**Android**: Compatible with arm64-v8a, x86_64 architectures.

## Installation

```sh
flutter pub add circom_witnesscalc
```

## Usage

#### calculateWitness

Function takes inputs json string and graph data file bytes and returns witness bytes.

```dart
import 'package:circom_witnesscalc/circom_witnesscalc.dart';

// ...

final String inputs = await rootBundle.loadString("assets/authV2_inputs.json");
final Uint8List graphData = (await rootBundle.load("assets/authV2.wcd")).buffer.asUint8List();
final proof = await CircomWitnesscalc().calculateWitness(inputs, graphData);
```

## Example App

Check out the [example app](./example) and [example README](./example/README.md) for a working example.

## License

circom-witnesscalc-flutter is part of the iden3 project and licensed under MIT and APACHE 2.0 licences. Please check the [LICENSE-MIT](./LICENSE-MIT.txt) and [LICENSE-APACHE](./LICENSE-APACHE.txt) files for more details.