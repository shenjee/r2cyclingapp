import 'r2_account.dart';
import 'r2_group.dart';

class R2UserProfile {
  R2Account _account;
  R2Group _group;

  R2UserProfile({
    required R2Account account,
    required R2Group group,
  })
      : _account = account,
        _group = group;

  // Getter and Setter for account
  R2Account get account => _account;

  set account(R2Account value) {
    _account = value;
  }

  // Getter and Setter for group
  R2Group get group => _group;

  set group(R2Group value) {
    _group = value;
  }
}