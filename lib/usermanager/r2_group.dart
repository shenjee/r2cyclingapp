class R2Group {
  final int _groupId;
  String _groupCode;
  R2Group({
    required int groupId,
    String? groupCode,
  })
      : _groupId = groupId,
        _groupCode = groupCode ?? 'G$groupId';

  int get groupId => _groupId;

  String get groupCode => _groupCode;
  set groupCode(String value) {
    _groupCode = value;
  }

  // Convert R2Group to Map
  Map<String, dynamic> toMap() {
    return {
      'groupId': _groupId,
      'groupCode': _groupCode ?? 'G$_groupId',
    };
  }

  // Create R2Account from Map
  factory R2Group.fromMap(Map<String, dynamic> map) {
    return R2Group(groupId: map['groupId'])
      ..groupCode = map['groupCode'];
  }
}