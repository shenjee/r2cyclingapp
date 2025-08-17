class R2Device {
  final String _deviceId;
  final String _model;
  final String _brand;
  final String _name;
  final String? _imageUrl;
  String? _bleAddress;
  String? _classicAddress;

  R2Device({
    required String deviceId,
    required String model,
    required String brand,
    required String name,
    String? imageUrl,
    String? bleAddress,
    String? classicAddress,
  }) : _deviceId = deviceId,
        _model = model,
        _brand = brand,
        _name = name,
        _imageUrl = imageUrl,
        _bleAddress = bleAddress,
        _classicAddress = classicAddress;

  String get deviceId => _deviceId;

  String get model => _model;

  String get brand => _brand;

  String get name => _name;

  String get imageUrl => _imageUrl ?? '';

  String get bleAddress => _bleAddress ?? '';
  set bleAddress(String value) {
    _bleAddress = value;
  }

  String get classicAddress => _classicAddress ?? '';
  set classicAddress(String value) {
    _classicAddress = value;
  }


  // Convert a R2Device into a Map.
  Map<String, dynamic> toMap() {
    return {
      'deviceId': _deviceId,
      'model': _model,
      'brand': _brand,
      'name': _name,
      'imageUrl': _imageUrl,
      'bleAddress': _bleAddress,
      'classicAddress': _classicAddress,
    };
  }

  // Convert a Map into a R2Device.
  factory R2Device.fromMap(Map<String, dynamic> map) {
    return R2Device(
      deviceId: map['deviceId'],
      model: map['model'],
      brand: map['brand'],
      name: map['name'],
      imageUrl: map['imageUrl'] ?? '',
      bleAddress: map['bleAddress'],
      classicAddress: map['classicAddress']
    );
  }
}