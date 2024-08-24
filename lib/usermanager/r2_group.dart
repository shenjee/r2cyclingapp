class R2Group {
  final int _gid;
  String _groupName;
  R2Group({
    required int gid,
    String? groupName,
  })
      : _gid = gid,
        _groupName = groupName ?? 'G$gid';

  int get gid => _gid;

  String get groupName => _groupName;
  set groupName(String value) {
    _groupName = value;
  }

  // Convert R2Group to Map
  Map<String, dynamic> toMap() {
    return {
      'gid': _gid,
      'groupName': _groupName ?? 'G$_gid',
    };
  }

  // Create R2Account from Map
  factory R2Group.fromMap(Map<String, dynamic> map) {
    return R2Group(gid: map['gid'])
      ..groupName = map['groupName'];
  }
}