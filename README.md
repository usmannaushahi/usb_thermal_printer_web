<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

This package helps the you to connect to your thermal usb printer via USB in Flutter Web and print. It has been tested in MP583 thermal printer.


## Features

printText: It allows you to print a simple text. You can center align or bold the text if you want to.

printEmptyLine: It prints an empty line to create add a space between two printed statements

printDottedLine: It prints a dotted line or you can use it as a divider

printRow: It takes two inputs and prints them as separate columns within a row. It is very helpful if you want to print key-value pairs i.e., product name and sale price.

printBarcode: It prints the barcode and prints the given barcode String beneath the barcode. 


## Getting started

You should have a web project as this package only supports Flutter Web for now. Before starting the printing, you need to call the pairDevice() function and provide
the vendorId, productId, interfaceNumber, and endpointNumber. The vendorId and productId are required and you can find them in the device description or check directly
from your system by connecting it via USB. The interfaceNumber and endpointNumber are default set as 0 and 1 respectively which works for most cases. However, if it does not
works, try to find the correct ones and change accordingly.


## Usage

The function below prints a sample receipt. NOTE: You may have to change the vendorId, productId, and may also provide interfaceNumber and endpointNumber to the function pairDevice().
```dart
//Create an instance of printer
  WebThermalPrinter _printer = WebThermalPrinter();

// A Dummy Function that you can call on any button and test.

printReceipt()
async
{
  
  //Pairing Device is required.
  await _printer.pairDevice(vendorId: 0x6868, productId: 0x0200);
  
  await _printer.printText('DKT Mart',
      bold: true, centerAlign: true);
  await _printer.printEmptyLine();
  
  await _printer.printRow("Products", "Sale");
  await _printer.printEmptyLine();
  
  for (int i = 0; i < 10; i++) {
    
    await _printer.printRow('A big title very big title ${i + 1}',
        '${(i + 1) * 510}.00 AED');
    await _printer.printEmptyLine();
    
  }
  
  await _printer.printDottedLine();
  await _printer.printEmptyLine();
  
  await _printer.printBarcode('123456');
  await _printer.printEmptyLine();
  
  await _printer.printEmptyLine();
  await _printer.closePrinter();
}
```


