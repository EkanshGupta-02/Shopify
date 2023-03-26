import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expirydate;
  String _userid;
  Timer _authtimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expirydate != null &&
        _expirydate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userid;
  }

  Future<void> _authenticate(
      String email, String password, String urlsegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlsegment?key=AIzaSyBTl5_EBMt4sLQY6U76OOxjYJU3JvSoadw');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      // print(json.decode(response.body));

      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userid = responseData['localId'];
      _expirydate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autologout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userid': _userid,
        'expirydate': _expirydate.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> Login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> autologin() async{
      final prefs = await SharedPreferences.getInstance();
      if(!prefs.containsKey('userData')){
        return false;
      }
          final extracteduserdata = json.decode(prefs.getString('userData')) as Map<String,Object>;
            final expirydate = DateTime.parse(extracteduserdata['expirydate']);
            if(expirydate.isBefore(DateTime.now())){
              return false;
            } 

            _token = extracteduserdata['token'];
            _userid = extracteduserdata['userid'];
            _expirydate = expirydate;
            notifyListeners();
            _autologout();
            return true;
  }

  Future<void> logout() async{
    _token = null;
    _userid = null;
    _expirydate = null;
    if (_authtimer != null) {
      _authtimer.cancel();
      _authtimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autologout() {
    if (_authtimer != null) {
      _authtimer.cancel();
    }
    final timetoexpire = _expirydate.difference(DateTime.now()).inSeconds;
    _authtimer = Timer(Duration(seconds: timetoexpire), logout);
  }
}
