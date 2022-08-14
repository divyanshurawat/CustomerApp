import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _userName = '',
      _cartCount = '',
      _curBal = '',
      _mob = '',
      _profilePic = '',
      _email = '',
      _gstno='',
       _aadhar='';
  String?  _userId = '';

  String? _curPincode = '';

  late SettingProvider settingsProvider;

  String get curUserName => _userName;

  String get curPincode => _curPincode ?? '';

  String get curCartCount => _cartCount;

  String get curBalance => _curBal;

  String get mob => _mob;

  String get profilePic => _profilePic;

  String? get userId => _userId;

  String get email => _email;
  String get aadhar => _aadhar;
  String get gstno=> _gstno;

  void setPincode(String pin) {
    _curPincode = pin;
    notifyListeners();
  }

  void setCartCount(String count) {
    _cartCount = count;
    notifyListeners();
  }

  void setBalance(String bal) {
    _curBal = bal;
    notifyListeners();
  }

  void setName(String count) {
    //settingsProvider.userName=count;
    _userName = count;
    notifyListeners();
  }

  void setMobile(String count) {
    _mob = count;
    notifyListeners();
  }

  void setProfilePic(String count) {
    _profilePic = count;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }
  void setAadhar(String aadhar) {
    _aadhar = aadhar;
    notifyListeners();
  }
  void setGST(String gstno) {
    _gstno = gstno;
    notifyListeners();
  }
  void setUserId(String? count) {
    _userId = count;
  }
}
