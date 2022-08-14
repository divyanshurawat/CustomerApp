import 'dart:async';
import 'dart:convert';

import 'package:eshop_multivendor/Helper/SqliteData.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/cropped_container.dart';
import 'package:eshop_multivendor/Provider/FavoriteProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/SendOtp.dart';
import 'package:eshop_multivendor/Screen/SignUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/call_button.dart';
import 'HomePage.dart';
import 'Verify_Otp.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  String? countryName;
  bool
  buttonPressed =false;

  String? verificationID;
  FocusNode? passFocus, monoFocus = FocusNode();
                        final GlobalKey<FormState> _otpformkey = GlobalKey<FormState>();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool visible = false;
  bool isDialog = false;
  bool isPassword = true;
  String? password,
      mobile,
      username,
      email,
      id,
      mobileno,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude,
      image,
      active,
      otp,gstno, aadhar;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;

  AnimationController? buttonController;
  var db = DatabaseHelper();
  bool isShowPass = true;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    super.initState();
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }
  void validateAndSubmitOTP() async {
    if (validate()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (isPassword) {
        getLoginUser();
      } else {
        getLoginOTPUser();
      }
    } else {
      Future.delayed(const Duration(seconds: 2)).then((_) async {
        await buttonController!.reverse();
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
      });
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  bool validate() {
    final form = _otpformkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  setSnackbar(String msg, BuildContext context) {
    ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
      ),
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
      elevation: 1.0,
    ));
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.only(top: kToolbarHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            noIntImage(),
            noIntText(context),
            noIntDec(context),
            AppBtn(
              title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                _playAnimation();

                Future.delayed(const Duration(seconds: 2)).then(
                  (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                              builder: (BuildContext context) => super.widget));
                    } else {
                      await buttonController!.reverse();
                      if (mounted) {
                        setState(
                          () {},
                        );
                      }
                    }
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> getLoginOTPUser() async {
    String? token = await FirebaseMessaging.instance.getToken();
    var data = {MOBILE: mobileController.text, FCM_ID: token};
    print("parameter : $data");
    Response response =
        await post(getMobileLoginApi, body: data, headers: headers)
            .timeout(const Duration(seconds: timeOut));
    var getdata = json.decode(response.body);
    print("getdata : $getdata");
    bool error = getdata['error'];
    String? msg = getdata['message'];
    await buttonController!.reverse();
    if (!error) {
  //    setSnackbar(msg!, context);


      var i = getdata['data'][0];
      id = i[ID];
      username = i[USERNAME];
      email = i[EMAIL];
      mobile = i[MOBILE];
      city = i[CITY];
      area = i[AREA];
      address = i[ADDRESS];
      pincode = i[PINCODE];
      latitude = i[LATITUDE];
      longitude = i[LONGITUDE];
      image = i[IMAGE];
      active = i[ACTIVE];
      gstno= i[GSTNO];
      aadhar=i[AADHAAR];


      CUR_USERID = id;
     // print(active);
      print(aadhar);
  bool vale=  await  Navigator.push(
          context, MaterialPageRoute(builder: (context) => VerifyOtp(mobileNumber: mobileController.text,countryCode: "91",title: "1",)));

      // CUR_USERNAME = username;
      if(vale) {
        UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
        userProvider.setName(username ?? '');
        userProvider.setEmail(email ?? '');
        userProvider.setProfilePic(image ?? '');

        SettingProvider settingProvider =
        Provider.of<SettingProvider>(context, listen: false);

        settingProvider.saveUserDetail(
            id!,
            username,
            email,
            mobile,
            city,
            area,
            gstno,
            aadhar,
            address,
            pincode,
            latitude,
            longitude,
            image,
            context);
        offFavAdd().then((value) {
          db.clearFav();
          context.read<FavoriteProvider>().setFavlist([]);
          offCartAdd().then((value) {
            db.clearCart();
            offSaveAdd().then((value) {
              db.clearSaveForLater();


              if (active == 1) {
                setState(() {
                  isDialog = true;
                });
              } else {
                setState(() {
                  isDialog = false;
                });
              }
            });
          });
        });

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
        Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);

      }


     ///  Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
       //

    } else {
    //  setSnackbar(msg!, context);
      if(msg.toString()=="user doesnot exist") {
        return showDialog(
          context: context,
          builder: (ctx) =>
              AlertDialog(
                title: Image.asset("assets/images/unverified.png"),
                content: Text("Your request for approval sends to the admin. Once the admin verifies your profile, you will get a notification."),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text("Cancel"),
                  ),
                ],
              ),
        );
      }
    }
  }

  Future<void> getLoginUser() async {
    var data = {MOBILE: mobile, PASSWORD: password};
    print("parameter : $data");
    Response response =
        await post(getUserLoginApi, body: data, headers: headers)
            .timeout(const Duration(seconds: timeOut));
    var getdata = json.decode(response.body);
    print("getdata : $getdata");
    bool error = getdata['error'];
    String? msg = getdata['message'];
    await buttonController!.reverse();
    if (!error) {
      setSnackbar(msg!, context);


        var i = getdata['data'][0];
      id = i[ID];
      username = i[USERNAME];
      email = i[EMAIL];
      mobile = i[MOBILE];
      city = i[CITY];
      area = i[AREA];
      address = i[ADDRESS];
      pincode = i[PINCODE];
      latitude = i[LATITUDE];
      longitude = i[LONGITUDE];
      image = i[IMAGE];
      active = i[ACTIVE];
      gstno= i[GSTNO];
      aadhar=i[AADHAAR];

      CUR_USERID = id;
      // CUR_USERNAME = username;
      print(active);
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      userProvider.setName(username ?? '');
      userProvider.setEmail(email ?? '');
      userProvider.setProfilePic(image ?? '');

      SettingProvider settingProvider =
          Provider.of<SettingProvider>(context, listen: false);

      settingProvider.saveUserDetail(id!, username, email, mobile, city, area,gstno,aadhar,
          address, pincode, latitude, longitude, image, context);
      offFavAdd().then((value) {
        db.clearFav();
        context.read<FavoriteProvider>().setFavlist([]);
        offCartAdd().then((value) {
          db.clearCart();
          offSaveAdd().then((value) {
            db.clearSaveForLater();

            if (active == 1) {
              setState(() {
                isDialog = true;
              });

              // Navigator.pushReplacementNamed(context, '/home',);

            } else {
              setState(() {
                isDialog = false;
              });
            }
          });
        });
      });

       Navigator.pushReplacement(
           context, MaterialPageRoute(builder: (context) => HomePage()));
       Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);


       } else {

      setSnackbar(msg!, context);
      if(msg.toString()=="Account is inactive") {
        return showDialog(
          context: context,
          builder: (ctx) =>
              AlertDialog(
                title: Image.asset("assets/images/unverified.png"),
                content: Text("Your request for approval sends to the admin. Once the admin verifies your profile, you will get a notification."),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text("Cancel"),
                  ),
                ],
              ),
        );
      }
    }
  }

  Future<void> offFavAdd() async {
    List favOffList = await db.getOffFav();
    if (favOffList.isNotEmpty) {
      for (int i = 0; i < favOffList.length; i++) {
        _setFav(favOffList[i]['PID']);
      }
    }
  }

  _setFav(String pid) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: pid};
        Response response =
            await post(setFavoriteApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata['error'];
        String? msg = getdata['message'];
        if (!error) {
        } else {
          setSnackbar(msg!, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  Future<void> offCartAdd() async {
    List cartOffList = await db.getOffCart();

    if (cartOffList.isNotEmpty) {
      for (int i = 0; i < cartOffList.length; i++) {
        addToCartCheckout(cartOffList[i]['VID'], cartOffList[i]['QTY']);
      }
    }
  }

  Future<void> addToCartCheckout(String varId, String qty) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_VARIENT_ID: varId /*cartList[index].varientId*/,
          USER_ID: CUR_USERID,
          QTY: qty,
        };

        Response response =
            await post(manageCartApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) _isNetworkAvail = false;

      setState(() {});
    }
  }

  Future<void> offSaveAdd() async {
    List saveOffList = await db.getOffSaveLater();

    if (saveOffList.isNotEmpty) {
      for (int i = 0; i < saveOffList.length; i++) {
        saveForLater(saveOffList[i]['VID'], saveOffList[i]['QTY']);
      }
    }
  }

  saveForLater(String vid, String qty) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_VARIENT_ID: vid,
          USER_ID: CUR_USERID,
          QTY: qty,
          SAVE_LATER: '1'
        };

        Response response =
            await post(manageCartApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata['error'];
        String? msg = getdata['message'];
        if (!error) {
        } else {
          setSnackbar(msg!, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  welcomeEshopTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30.0),
      child: Text(
        getTranslated(context, 'WELCOME_ESHOP')!,
        style: Theme.of(context).textTheme.subtitle1!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  signInTxt() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(
          top: 40.0,
        ),
        child: Center(
          child: Text(
            getTranslated(context, 'WELCOME_ESHOP')!,
            style: Theme.of(context).textTheme.headline6!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.8),
          ),
        ));
  }

  signInSubTxt() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(
          top: 13.0,
        ),
        child: Center(
          child: Text(
            getTranslated(context, 'INFO_FOR_LOGIN')!,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                color:
                    Theme.of(context).colorScheme.fontColor.withOpacity(0.38),
                fontWeight: FontWeight.bold),
          ),
        ));
  }

  setMobileNo() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Container(
        height: 53,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black54),
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: TextFormField(

          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(passFocus);
          },
          //initialValue: nameController.text,
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 13),
          keyboardType: TextInputType.number,
          controller: mobileController,
          focusNode: monoFocus,

          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.phone),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 18,
              ),
              hintText: getTranslated(
                context,
                'MOBILEHINT_LBL',
              )!,
              hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              fillColor: Theme.of(context).colorScheme.lightWhite,
              border: InputBorder.none),
          validator: (val) => validateMob(
              val!,
              getTranslated(context, 'MOB_REQUIRED'),
              getTranslated(context, 'VALID_MOB')),
          onSaved: (String? value) {
            mobile = value;
          },
        ),
      ),
    );
  }

  setOTP() {
    return Form(
      key:_otpformkey,
      child: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Container(
          height: 53,
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black54),
            borderRadius: BorderRadius.circular(10.0),
          ),
          alignment: Alignment.center,
          child: TextFormField(
            //initialValue: nameController.text,
            style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
                fontWeight: FontWeight.bold,
                fontSize: 13),
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(passFocus);
            },

            keyboardType: TextInputType.number,
           // obscureText: isShowPass,
            controller: otpController,
            focusNode: passFocus,
            textInputAction: TextInputAction.next,
            onChanged: (v) {
              setState(() {
                isPassword = false;
              });
            },
            validator: (val) => validatePass(
                val!,
                "OTP Required",
                "Please enter six digit otp"),
            onSaved: (String? value) {
              otp = value;
            },
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 15,
                ),
                suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        // isShowPass = !isShowPass;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10.0),
                      child: Icon(
                        isShowPass ? Icons.visibility : Icons.visibility_off,
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.4),
                        size: 22,
                      ),
                    )),
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 40, maxHeight: 20),
                hintText: "Requested OTP",
                hintStyle: TextStyle(
                    color:
                        Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
                fillColor: Theme.of(context).colorScheme.lightWhite,
                border: InputBorder.none),
          ),
        ),
      ),
    );
  }

  setPass() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Container(
        height: 53,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black54),
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: TextFormField(
          //initialValue: nameController.text,
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 13),
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(passFocus);
          },
          onChanged: (v) {
            setState(() {
              isPassword = true;
            });
          },

          keyboardType: TextInputType.text,
          obscureText: isShowPass,
          controller: passwordController,
          focusNode: passFocus,
          textInputAction: TextInputAction.next,
          validator: (val) => validatePass(
              val!,
              getTranslated(context, 'PWD_REQUIRED'),
              getTranslated(context, 'PWD_LENGTH')),
          onSaved: (String? value) {
            password = value;
          },
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 15,
              ),
              suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      isShowPass = !isShowPass;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 10.0),
                    child: Icon(
                      isShowPass ? Icons.visibility : Icons.visibility_off,
                      color: Theme.of(context)
                          .colorScheme
                          .fontColor
                          .withOpacity(0.4),
                      size: 22,
                    ),
                  )),
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 40, maxHeight: 20),
              hintText: getTranslated(context, 'PASSHINT_LBL')!,
              hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              fillColor: Theme.of(context).colorScheme.lightWhite,
              border: InputBorder.none),
        ),
      ),
    );
  }

  requestOTPPass() {
    return buttonPressed?Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                height: 20,
                  width: 20,
                  child: CircularProgressIndicator()),
            ],
          ),
        ),
      ],
    ):Padding(
        padding: const EdgeInsetsDirectional.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: ()async {
                setState(() {
                  isPassword = false;
                });
                if(mobileController.text.length==10){
                 // getLoginOTPUser();

                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>VerifyOtp(mobileNumber: mobileController.text,countryCode: '91',countrycode: '91',title: "OTPLogin",)));
             //  setState(() {
             //    buttonPressed =true;,
             //  });
             //  print(mobile);
             //
             //
             //  await FirebaseAuth.instance.verifyPhoneNumber(
             //    phoneNumber: '+91${mobileController.text}',
             //    verificationCompleted: (PhoneAuthCredential credential) {
             //      setState(() {
             //        buttonPressed =false;
             //      });
             //    },
             //    verificationFailed: (FirebaseAuthException e) {
             //      setSnackbar("$e", context) ;
             //
             //        setState(() {
             //          buttonPressed =false;
             //        });
             //
             //
             //
             //    },
             //    codeSent: (String verificationId, int? resendToken) async{
             //      setState(() {
             //        buttonPressed =false;
             //      });
             //      setSnackbar("Your OTP has been sent", context) ;
             //
             //      // Create a PhoneAuthCredential with the code
             //      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: "${otpController.text}");
             //
             //      // Sign the user in (or link) with the credential
             //      await FirebaseAuth.instance.signInWithCredential(credential);
             //    },
             //    codeAutoRetrievalTimeout: (String verificationId) {
             //      setState(() {
             //        buttonPressed =false;
             //      });
             //    },
             //  );
                }else{
                 setSnackbar("Please enter the mobile number", context) ;
                }






                //Navigator.push(
                //    context,
                //    CupertinoPageRoute(
                //        builder: (context) => SendOtp(
                //          title:
                //          getTranslated(context, 'FORGOT_PASS_TITLE'),
                //        )));
              },
              child: Text("Request OTP",
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),
          ],
        ));
  }

  forgetPass() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(top: 30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => SendOtp(
                              title:
                                  getTranslated(context, 'FORGOT_PASS_TITLE'),
                            )));
              },
              child: Text(getTranslated(context, 'FORGOT_PASSWORD_LBL')!,
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ],
        ));
  }

  setDontHaveAcc() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(getTranslated(context, 'DONT_HAVE_AN_ACC')!,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold)),
          InkWell(
              onTap: () {
                Navigator.of(context).push(CupertinoPageRoute(
                  builder: (BuildContext context) => SignUp(),
                ));
              },
              child: Text(
                getTranslated(context, 'SIGN_UP_LBL')!,
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ))
        ],
      ),
    );
  }

  loginBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Center(
        child: AppBtn(
          title: getTranslated(context, 'SIGNIN_LBL'),
          btnAnim: buttonSqueezeanimation,
          btnCntrl: buttonController,
          onBtnSelected: () async {
            if(isPassword){
                validateAndSubmit();
            } else{
                 validateAndSubmitOTP();
            }

          },
        ),
      ),
    );
  }

  skipSignInBtn() {
    return Container(
      padding: const EdgeInsets.only(top: 13),
      alignment: Alignment.topRight,
      child: CupertinoButton(
        child: Container(
            width: 60,
            height: 50,
            alignment: FractionalOffset.center,
            decoration: const BoxDecoration(
              color: colors.whiteTemp,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Text(getTranslated(context, 'SKIP_SIGNIN_LBL')!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: colors.primary, fontWeight: FontWeight.bold))),
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          floatingActionButton: FloatingActionButton(onPressed: () {
            call_button();
          },
            child: Image.asset("assets/images/contact.png"),
            backgroundColor: colors.primary,

          ),
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          key: _scaffoldKey,
          body: Stack(
            children: [
              if (_isNetworkAvail) SingleChildScrollView(
                    child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(color: Colors.white),
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 23, left: 23, right: 23, bottom: 50),
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formkey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(height: 8,)
                                   //   skipSignInBtn(),
                                    ],
                                  ),
                                  getLogo(),
                                  signInTxt(),
                                  signInSubTxt(),
                                  setMobileNo(),
                                  setPass(),
                                  forgetPass(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(height: 1,color: Colors.black12,width: MediaQuery.of(context).size.width/2*0.56,),
                                      Text("or",style: TextStyle(color: Colors.black45),),

                                      Container(height: 1,color: Colors.black12,width: MediaQuery.of(context).size.width/2*0.56,)

                                    ],
                                  ),
                                 // setOTP(),


                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      requestOTPPass()

                                    ],
                                  ),
                                  loginBtn(),
                                  setDontHaveAcc(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ) else noInternet(context),

              isDialog?AlertDialog(title: Text(""),):Text("")
              //    active==null?Text(""):isDialog?AlertDialog(
              //      title: Image.asset("assets/images/unverified.png"),
              //      content: Text("You are not verified user. Wait for the approval from admin"),
              //
              //    ):AlertDialog(
              //       title: Image.asset("assets/images/verified.png"),
              //       content: Text("You are successfully Verified"),
              //
              //     )
            ],
          )),
    );
  }

  getLoginContainer() {
    return Positioned.directional(
      start: MediaQuery.of(context).size.width * 0.025,
      // end: width * 0.025,
      // top: width * 0.45,
      top: MediaQuery.of(context).size.height * 0.2, //original
      //    bottom: height * 0.1,
      textDirection: Directionality.of(context),
      child: ClipPath(
        clipper: ContainerClipper(),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom * 0.8),
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.95,
          color: Theme.of(context).colorScheme.white,
          child: Form(
            key: _formkey,
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      setSignInLabel(),
                      setMobileNo(),
                      setPass(),
                      loginBtn(),
                      setDontHaveAcc(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLogo() {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Color(0xff1273ba), borderRadius: BorderRadius.circular(20)),
        child: Center(
          child: Image.asset(
            'assets/images/logorect.png',
            alignment: Alignment.center,
            height: 250,
            width: 250,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  Widget setSignInLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          getTranslated(context, 'SIGNIN_LBL')!,
          style: const TextStyle(
            color: colors.primary,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
