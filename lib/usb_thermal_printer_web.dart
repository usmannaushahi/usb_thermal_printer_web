library usb_thermal_printer_web;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:usb_device/usb_device.dart'
if (dart.library.io) 'usb_device_empty.dart';

class WebThermalPrinter {
  final UsbDevice usbDevice = UsbDevice();
  var pairedDevice;

  //By Default, it is usually 0
  var interfaceNumber;

  //By Default, it is usually 1
  var endpointNumber;

  Future<void> pairDevice(
      {required int vendorId,
        required int productId,
        int? interfaceNo,
        int? endpointNo}) async {
    if (kIsWeb == false) {
      return;
    }
    interfaceNumber = interfaceNo ?? 0;
    endpointNumber = endpointNo ?? 1;
    pairedDevice ??= await usbDevice.requestDevices(
        [DeviceFilter(vendorId: vendorId, productId: productId)]);
    await usbDevice.open(pairedDevice);
    await usbDevice.claimInterface(pairedDevice, interfaceNumber);
  }

  Future<void> printRow(
      String title,
      String value,
      ) async {
    if (!kIsWeb) {
      return;
    }
    var titleColumnWidth = 18;
    var valueColumnWidth = 12;

    // Split the title and value into separate rows
    var titleRows = _splitStringIntoRows(title, titleColumnWidth);
    var valueRows = _splitStringIntoRows(value, valueColumnWidth);

    // Print each row separately
    for (var i = 0; i < max(titleRows.length, valueRows.length); i++) {
      var titleRow = titleRows.length > i ? titleRows[i] : '';
      var valueRow = valueRows.length > i ? valueRows[i] : '';

      var encodedTitle = utf8.encode(titleRow.padRight(titleColumnWidth));
      var encodedValue = utf8.encode(valueRow.padLeft(valueColumnWidth));

      var buffer = Uint8List.fromList([
        ...encodedTitle,
        ...encodedValue,
        0x0A, // Line feed
      ]).buffer;

      await usbDevice.transferOut(pairedDevice, endpointNumber, buffer);
    }
  }

  List<String> _splitStringIntoRows(String str, int rowWidth) {
    var rows = <String>[];
    var currentRow = '';
    for (var word in str.split(' ')) {
      if ((currentRow + word).length > rowWidth) {
        rows.add(currentRow);
        currentRow = '';
      }
      currentRow += word + ' ';
    }
    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }
    return rows;
  }

  Future<void> printBarcode(String barcodeData) async {
    if (kIsWeb == false) {
      return;
    }
    var barcodeBytes = Uint8List.fromList([
      0x1d, 0x77, 0x02, // Set barcode height to 64 dots (default is 50 dots)
      0x1d, 0x68, 0x64, // Set barcode text position to below barcode
      0x1d, 0x48, 0x02, // Set barcode text font to Font B (default is Font A)
      0x1d, 0x6b, 0x49, // Print Code 128 barcode with text
      barcodeData.length + 2, // Length of data to follow (barcodeData + {B})
      0x7b, 0x42, // Start Code B
    ]);
    var barcodeStringBytes = utf8.encode(barcodeData);
    var data = Uint8List.fromList([...barcodeBytes, ...barcodeStringBytes]);

    var centerAlignBytes = Uint8List.fromList([
      0x1b, 0x61, 0x01, // Center align
    ]);
    var centerAlignData = centerAlignBytes.buffer.asByteData();
    var resetAlignBytes = Uint8List.fromList([
      0x1b, 0x61, 0x00, // Reset align to left
    ]);
    var resetAlignData = resetAlignBytes.buffer.asByteData();

    await usbDevice.transferOut(
        pairedDevice, endpointNumber, centerAlignData.buffer);
    await usbDevice.transferOut(pairedDevice, endpointNumber, data.buffer);
    await usbDevice.transferOut(
        pairedDevice, endpointNumber, resetAlignData.buffer);
  }

  Future<void> printText(
      String text, {
        bool? bold,
        bool centerAlign = false,
      }) async {
    if (kIsWeb == false) {
      return;
    }
    var encodedText =
    utf8.encode((bold ?? false) ? "\x1B[$text\x1B\n" : "$text\n");
    if (centerAlign) {
      var width = 28; // Change this to adjust the width of the printer
      var leftPadding = ((width - text.length) / 2).floor();
      var rightPadding = width - text.length - leftPadding;
      var paddingString =
          ''.padLeft(leftPadding) + text + ''.padRight(rightPadding);
      encodedText = utf8.encode("\n$paddingString\n");
    }
    var buffer = Uint8List.fromList(encodedText).buffer;

    await usbDevice.transferOut(pairedDevice, endpointNumber, buffer);
  }

  Future<void> printEmptyLine() async {
    if (kIsWeb == false) {
      return;
    }
    var encodedText = utf8.encode("\n");
    var buffer = Uint8List.fromList(encodedText).buffer;
    await usbDevice.transferOut(pairedDevice, endpointNumber, buffer);
  }

  Future<void> printDottedLine() async {
    if (kIsWeb == false) {
      return;
    }
    var encodedText = utf8.encode("\n--------------------------------\n");
    var buffer = Uint8List.fromList(encodedText).buffer;
    await usbDevice.transferOut(pairedDevice, endpointNumber, buffer);
  }

  Future<void> closePrinter() async {
    if (kIsWeb == false) {
      return;
    }
    await usbDevice.close(pairedDevice);
  }
}
