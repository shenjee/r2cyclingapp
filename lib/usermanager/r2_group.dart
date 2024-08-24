class R2Group {
  final int _gid;
  R2Group({
    required int gid,
  }) : _gid = gid;

  int get gid => _gid;

  // Convert R2Group to Map
  Map<String, dynamic> toMap() {
    return {
      'gid': _gid,
    };
  }

  // Create R2Account from Map
  factory R2Group.fromMap(Map<String, dynamic> map) {
    return R2Group(gid: map['gid']);
  }
}