class R2Device {
  final String brand;
  final String id;
  final String name;

  R2Device({required this.brand, required this.id, required this.name});

  // Convert a R2Device into a Map.
  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'id': id,
      'name': name,
    };
  }

  // Convert a Map into a R2Device.
  factory R2Device.fromMap(Map<String, dynamic> map) {
    return R2Device(
      brand: map['brand'],
      id: map['id'],
      name: map['name'],
    );
  }
}