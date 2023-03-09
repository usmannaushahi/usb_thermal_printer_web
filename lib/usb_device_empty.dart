import 'dart:typed_data';

class UsbDevice {
  requestDevices(List<DeviceFilter> filters) {
    return;
  }

  /// Start session with the device
  open(dynamic device) {
    return;
  }

  /// close session with the device
  close(dynamic device) {
    return;
  }

  /// Claims the interface of the device
  claimInterface(dynamic device, int interfaceNumber) {
    return;
  }

  transferOut(dynamic device, endpointNumber, ByteBuffer data) {
    return;
  }
}

class DeviceFilter {
  final int vendorId;
  final int productId;

  DeviceFilter({
    required this.vendorId,
    required this.productId,
  });
}
