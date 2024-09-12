class R2Device {
  final String _id;
  final String _brand;
  final String _name;
  String? _bleAddress;
  String? _classicAddress;

  R2Device({
    required String id,
    required String brand,
    required String name,
    String? bleAddress,
    String? classicAddress,
  }) : _id = id,
        _brand = brand,
        _name = name,
        _bleAddress = bleAddress,
        _classicAddress = classicAddress;

  String get id => _id;

  String get brand => _brand;

  String get name => _name;

  String get bleAddress => _bleAddress!;
  set bleAddress(String value) {
    _bleAddress = value;
  }

  String get classicAddress => _classicAddress!;
  set classicAddress(String value) {
    _classicAddress = value;
  }


  // Convert a R2Device into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'brand': _brand,
      'name': _name,
      'bleAddress': _bleAddress,
      'classicAddress': _classicAddress,
    };
  }

  // Convert a Map into a R2Device.
  factory R2Device.fromMap(Map<String, dynamic> map) {
    return R2Device(
      brand: map['brand'],
      id: map['id'],
      name: map['name'],
      bleAddress: map['bleAddress'],
      classicAddress: map['classicAddress']
    );
  }
}