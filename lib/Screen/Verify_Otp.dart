import 'dart:async';
import 'dart:convert';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Screen/Add_Address.dart';
import 'package:eshop_multivendor/Screen/HomePage.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:eshop_multivendor/Screen/Set_Password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Provider/UserProvider.dart';
import 'SignUp.dart';

class VerifyOtp extends StatefulWidget {
  final String? mobileNumber, countryCode, title, mobile,name,email,address,gstno,aadhaar,password,countrycode,referCode,friendCode;


  const VerifyOtp(
      {Key? key,
      required String this.mobileNumber,
      this.countryCode,
        this.address,
        this.gstno,
        this.name,
        this.friendCode,

        this.mobile,
        this.password,
        this.email,
        this.aadhaar,
        this.countrycode,this.referCode,
      this.title})
      : super(key: key);

  @override
  _MobileOTPState createState() => _MobileOTPState();
}

class _MobileOTPState extends State<VerifyOtp> with TickerProviderStateMixin {
  final dataKey = GlobalKey();
  String? password;
  String? otp,id,mobile,name, email;
  bool isCodeSent = false;
  late String _verificationId;
  String signature = '';
  bool _isClickable = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  @override
  void initState() {
    super.initState();
    getUserDetails();
    getSingature();
    _onVerifyCode();

    Future.delayed(const Duration(seconds: 60)).then((_) {
      _isClickable = true;
    });
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

  Future<void> getSingature() async {
    signature = await SmsAutoFill().getAppSignature;
    print("singnature : $signature");
    SmsAutoFill().listenForCode;
  }

  getUserDetails() async {
    if (mounted) setState(() {});
  }

  Future<void> checkNetworkOtp() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      if (_isClickable) {
        _onVerifyCode();
      } else {
        setSnackbar(getTranslated(context, 'OTPWR')!);
      }
    } else {
      if (mounted) setState(() {});

      Future.delayed(const Duration(seconds: 60)).then((_) async {
        bool avail = await isNetworkAvailable();
        if (avail) {
          if (_isClickable) {
            _onVerifyCode();
          } else {
            setSnackbar(getTranslated(context, 'OTPWR')!);
          }
        } else {
          await buttonController!.reverse();
          setSnackbar(getTranslated(context, 'somethingMSg')!);
        }
      });
    }
  }

  Widget verifyBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: AppBtn(
            title: getTranslated(context, 'VERIFY_AND_PROCEED'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _onFormSubmitted();
            }),
      ),
    );
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme
            .of(context)
            .colorScheme
            .fontColor),
      ),
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .lightWhite,
      elevation: 1.0,
    ));
  }


  void _onVerifyCode() async {


    if (mounted) {
      setState(() {

        isCodeSent = true;
      });
    }
    PhoneVerificationCompleted verificationCompleted() {
      return (AuthCredential phoneAuthCredential) {
        _firebaseAuth
            .signInWithCredential(phoneAuthCredential)
            .then((UserCredential value) {
          if (value.user != null) {
            SettingProvider settingsProvider =
            Provider.of<SettingProvider>(context, listen: false);

            setSnackbar(getTranslated(context, 'OTPMSG')!);
            settingsProvider.setPrefrence(MOBILE, widget.mobileNumber!);
            settingsProvider.setPrefrence(COUNTRY_CODE, widget.countryCode!);
            if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
           getRegisterUser();
            } else if(widget.title=='OTPLogin'){
              getLoginUser();
            }else if (widget.title ==
                getTranslated(context, 'FORGOT_PASS_TITLE')) {
              Future.delayed(const Duration(seconds: 2)).then((_) {
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                    builder: (context) =>
                        SetPass(
                          mobileNumber: widget.mobileNumber!,
                        ),
                  ),
                );
              });
            }
          } else {
            setSnackbar(getTranslated(context, 'OTPERROR')!);
          }
        }).catchError((error) {
          setSnackbar(error.toString());
        });
      };
    }



    // final PhoneVerificationCompleted verificationCompleted =
    //     (AuthCredential phoneAuthCredential) {
    //   _firebaseAuth
    //       .signInWithCredential(phoneAuthCredential)
    //       .then((UserCredential value) {
    //     if (value.user != null) {
    //       SettingProvider settingsProvider =
    //           Provider.of<SettingProvider>(context, listen: false);

    //       setSnackbar(getTranslated(context, 'OTPMSG')!);
    //       settingsProvider.setPrefrence(MOBILE, widget.mobileNumber!);
    //       settingsProvider.setPrefrence(COUNTRY_CODE, widget.countryCode!);
    //       if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
    //         Future.delayed(const Duration(seconds: 2)).then((_) {
    //           Navigator.pushReplacement(context,
    //               CupertinoPageRoute(builder: (context) => const SignUp()));
    //         });
    //       } else if (widget.title ==
    //           getTranslated(context, 'FORGOT_PASS_TITLE')) {
    //         Future.delayed(const Duration(seconds: 2)).then((_) {
    //           Navigator.pushReplacement(
    //             context,
    //             CupertinoPageRoute(
    //               builder: (context) => SetPass(
    //                 mobileNumber: widget.mobileNumber!,
    //               ),
    //             ),
    //           );
    //         });
    //       }
    //     } else {
    //       setSnackbar(getTranslated(context, 'OTPERROR')!);
    //     }
    //   }).catchError((error) {
    //     setSnackbar(error.toString());
    //   });
    // };
    PhoneVerificationFailed verificationFailed() {
      return (FirebaseAuthException authException) {
        if (mounted) {
          setState(() {
            isCodeSent = false;
          });
        }
      };
    }

    // final PhoneVerificationFailed verificationFailed =
    //     (FirebaseAuthException authException) {
    //   if (mounted) {
    //     setState(() {
    //       isCodeSent = false;
    //     });
    //   }
    // };

    PhoneCodeSent codeSent() {
      return (String verificationId, [int? forceResendingToken]) async {
        _verificationId = verificationId;
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
          });
        }
      };
    }

    // final PhoneCodeSent codeSent =
    //     (String verificationId, [int? forceResendingToken]) async {
    //   _verificationId = verificationId;
    //   if (mounted) {
    //     setState(() {
    //       _verificationId = verificationId;
    //     });
    //   }
    // };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout() {
      return (String verificationId) {
        _verificationId = verificationId;
        if (mounted) {
          setState(() {
            _isClickable = true;
            _verificationId = verificationId;
          });
        }
      };
    }

    // final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
    //     (String verificationId) {
    //   _verificationId = verificationId;
    //   if (mounted) {
    //     setState(() {
    //       _isClickable = true;
    //       _verificationId = verificationId;
    //     });
    //   }
    // };

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: '+${widget.countryCode}${widget.mobileNumber}',
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted(),
      verificationFailed: verificationFailed(),
      codeSent: codeSent(),
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout(),
    );
  }
  Future<void> getRegisterUserOTP() async {
    String? token = await FirebaseMessaging.instance.getToken();

    try {
      var data = {
        MOBILE:widget.mobileNumber,
        NAME: widget.mobileNumber,
        FCM_ID:token,
        COUNTRY_CODE: widget.countrycode,

      };

      Response response =
      await post(getUserSignUpApi2, body: data, headers: headers)
          .timeout(const Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      bool error = getdata['error'];
      String? msg = getdata['message'];
      await buttonController!.reverse();
      if (!error) {
        setSnackbar(getTranslated(context, 'REGISTER_SUCCESS_MSG')!);
        var i = getdata['data'][0];
        print(i);


        id = i[ID];
        name = i[USERNAME];
        email = i[EMAIL];
        mobile = i[MOBILE];
        //countrycode=i[COUNTRY_CODE];
        CUR_USERID = id;
        Future.delayed(const Duration(seconds: 1)).then((_) {
          Navigator.pushReplacement(context,
              CupertinoPageRoute(builder: (context) => const Login()));
        });
        // CUR_USERNAME = name;

        // UserProvider userProvider = context.read<UserProvider>();
        // userProvider.setName(name ?? '');

        //  SettingProvider settingProvider = context.read<SettingProvider>();
        //  settingProvider.saveUserDetail(id!, name, email, mobile, city, area,"","",
        //      address, pincode, latitude, longitude, '', context);

        //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
      } else {
        setSnackbar(msg!);
      }
      if (mounted) setState(() {});
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!);
      await buttonController!.reverse();
    }
  }

  Future<void> getLoginUser() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("hfxgfhx");
    var data = {MOBILE: widget.mobileNumber, FCM_ID: token};
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



      var i = getdata['data'][0];
      id = i[ID];
      print(id);
     // username = i[USERNAME];
      email = i[EMAIL];
      mobile = i[MOBILE];
      latitude = i[LATITUDE];
      longitude = i[LONGITUDE];


      CUR_USERID = id;

      UserProvider userProvider =
      Provider.of<UserProvider>(context, listen: false);
      userProvider.setName(mobile ?? '');
      userProvider.setEmail(email ?? '');
      userProvider.setProfilePic('' ?? '');

      SettingProvider settingProvider =
      Provider.of<SettingProvider>(context, listen: false);

      settingProvider.saveUserDetail(id!, mobile, email, mobile, "", "",'',"",
          '', '', latitude, longitude, '', context);

      print("DOnw");

     Navigator.pushReplacement(
         context, MaterialPageRoute(builder: (context) => HomePage()));
     Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);


    } else {
      print(msg!);

    //  setSnackbar(msg!, context);
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
      }else if(msg.toString()=='user doesnot exist'){
        getRegisterUserOTP();
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


  Future<void> getRegisterUser() async {
    String? token = await FirebaseMessaging.instance.getToken();

    try {
      var data = {
        MOBILE:widget.mobile,
        FCM_ID:token,
        NAME: widget.name,
        EMAIL: widget.email,
        ADDRESS:widget.address,
        GSTNO:widget.gstno.toString(),
        AADHAAR:widget.aadhaar.toString(),
        PASSWORD: widget.password,
        COUNTRY_CODE: widget.countrycode,
        REFERCODE: widget.referCode,
        FRNDCODE: widget.friendCode
      };

      Response response =
      await post(getUserSignUpApi, body: data, headers: headers)
          .timeout(const Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      bool error = getdata['error'];
      String? msg = getdata['message'];
      await buttonController!.reverse();
      if (!error) {
        setSnackbar(getTranslated(context, 'REGISTER_SUCCESS_MSG')!);
        var i = getdata['data'][0];
        print(i);


        id = i[ID];
        name = i[USERNAME];
        email = i[EMAIL];
        mobile = i[MOBILE];
        //countrycode=i[COUNTRY_CODE];
        CUR_USERID = id;
        Future.delayed(const Duration(seconds: 1)).then((_) {
          Navigator.pushReplacement(context,
              CupertinoPageRoute(builder: (context) => const Login()));
        });
        // CUR_USERNAME = name;

        // UserProvider userProvider = context.read<UserProvider>();
        // userProvider.setName(name ?? '');

        //  SettingProvider settingProvider = context.read<SettingProvider>();
        //  settingProvider.saveUserDetail(id!, name, email, mobile, city, area,"","",
        //      address, pincode, latitude, longitude, '', context);

        //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
      } else {
        setSnackbar(msg!);
      }
      if (mounted) setState(() {});
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!);
      await buttonController!.reverse();
    }
  }

  void _onFormSubmitted() async {

    print('Dtat');
    String code = otp!.trim();

    if (code.length == 6) {
      _playAnimation();
      AuthCredential authCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId, smsCode: code);

      _firebaseAuth
          .signInWithCredential(authCredential)
          .then((UserCredential value) async {
        if (value.user != null) {
          SettingProvider settingsProvider =
          Provider.of<SettingProvider>(context, listen: false);

          await buttonController!.reverse();
          setSnackbar(getTranslated(context, 'OTPMSG')!);
          settingsProvider.setPrefrence(MOBILE, widget.mobileNumber!);
          settingsProvider.setPrefrence(COUNTRY_CODE, widget.countryCode!);
          if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {

            getRegisterUser();

          } else if (widget.title ==
              getTranslated(context, 'FORGOT_PASS_TITLE')) {
            Future.delayed(const Duration(seconds: 2)).then((_) {
              Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                      builder: (context) =>
                          SetPass(mobileNumber: widget.mobileNumber!)));
            });
          }  else if(widget.title=='OTPLogin')  {
            print('Data');

            getLoginUser();
           // Navigator.pop(context,true);
         //   Navigator.pushReplacement(
         //       context, MaterialPageRoute(builder: (context) => HomePage()));
         //   Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);

          }
        } else {
          setSnackbar(getTranslated(context, 'OTPERROR')!);
           //Navigator.pop(context,true);
          await buttonController!.reverse();
        }
      }).catchError((error) async {
        setSnackbar(getTranslated(context, 'WRONGOTP')!);

        await buttonController!.reverse();
      });
    } else {
      setSnackbar(getTranslated(context, 'ENTEROTP')!);
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  getImage() {
    return Expanded(
      flex: 4,
      child: Center(
        child: SvgPicture.asset('assets/images/homelogo.svg'),
      ),
    );
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  monoVarifyText() {
    return Center(
      child: Padding(
          padding: const EdgeInsetsDirectional.only(
            top: 60.0,
          ),
          child: Text(getTranslated(context, 'MOBILE_NUMBER_VARIFICATION')!,
              style: Theme
                  .of(context)
                  .textTheme
                  .headline6!
                  .copyWith(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .fontColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                  letterSpacing: 0.8))),
    );
  }

  otpText() {
    return Center(
      child: Padding(
          padding: const EdgeInsetsDirectional.only(
            top: 13.0,
          ),
          child: Text(
            getTranslated(context, 'SENT_VERIFY_CODE_TO_NO_LBL')!,
            style: Theme
                .of(context)
                .textTheme
                .subtitle2!
                .copyWith(
              color: Theme
                  .of(context)
                  .colorScheme
                  .fontColor
                  .withOpacity(0.5),
              fontWeight: FontWeight.bold,
            ),
          )),
    );
  }

  mobText() {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: 5.0),
        child: Text(
          '+${widget.countryCode}-${widget.mobileNumber}',
          style: Theme
              .of(context)
              .textTheme
              .subtitle2!
              .copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget otpLayout() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30),
      child: PinFieldAutoFill(
        decoration: BoxLooseDecoration(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
                fontSize: 20, color: Theme
                .of(context)
                .colorScheme
                .fontColor),
            radius: const Radius.circular(12.0),
            // strokeWidth: 20,
            gapSpace: 12,
            bgColorBuilder: FixedColorBuilder(
                Colors.white),
            strokeColorBuilder: FixedColorBuilder(
                Theme
                    .of(context)
                    .colorScheme
                    .fontColor
                    .withOpacity(0.2))),
        currentCode: otp,
        codeLength: 6,
        onCodeChanged: (String? code) {
          otp = code;
        },
        onCodeSubmitted: (String code) {
          otp = code;
        },
      ),
    );
  }

  Widget resendText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30.0),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            getTranslated(context, 'DIDNT_GET_THE_CODE')!,
            style: Theme
                .of(context)
                .textTheme
                .caption!
                .copyWith(
                color: Theme
                    .of(context)
                    .colorScheme
                    .fontColor
                    .withOpacity(0.5),
                fontWeight: FontWeight.bold),
          ),
          InkWell(
              onTap: () async {
                await buttonController!.reverse();
                checkNetworkOtp();
              },
              child: Text(
                getTranslated(context, 'RESEND_OTP')!,
                style: Theme
                    .of(context)
                    .textTheme
                    .caption!
                    .copyWith(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .primary,
                    // decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold),
              ))
        ],
      ),
    );
  }

  expandedBottomView() {
    return Expanded(
      flex: 6,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
              child: Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin:
                const EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    monoVarifyText(),
                    otpText(),
                    mobText(),
                    otpLayout(),
                    verifyBtn(),
                    resendText(),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        key: _scaffoldKey,
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .white,
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
                top: 23,
                left: 23,
                right: 23,
                bottom: MediaQuery
                    .of(context)
                    .viewInsets
                    .bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getLogo(),
                monoVarifyText(),
                otpText(),
                mobText(),
                otpLayout(),
                resendText(),
                verifyBtn(),
                /* SizedBox(
                        height: deviceHeight! * 0.1,
                      ),
                      termAndPolicyTxt(),*/
              ],
            ),
          ),
        ));
  }

  // getLoginContainer() {
  //   return Positioned.directional(
  //     start: MediaQuery.of(context).size.width * 0.025,
  //     // end: width * 0.025,
  //     // top: width * 0.45,
  //     top: MediaQuery.of(context).size.height * 0.2, //original
  //     //    bottom: height * 0.1,
  //     textDirection: Directionality.of(context),
  //     child: ClipPath(
  //       clipper: ContainerClipper(),
  //       child: Container(
  //         alignment: Alignment.center,
  //         padding: EdgeInsets.only(
  //             bottom: MediaQuery.of(context).viewInsets.bottom * 0.6),
  //         height: MediaQuery.of(context).size.height * 0.7,
  //         width: MediaQuery.of(context).size.width * 0.95,
  //         color: Theme.of(context).colorScheme.white,
  //         child: Form(
  //           // key: _formkey,
  //           child: ScrollConfiguration(
  //             behavior: MyBehavior(),
  //             child: SingleChildScrollView(
  //               child: ConstrainedBox(
  //                 constraints: BoxConstraints(
  //                   maxHeight: MediaQuery.of(context).size.height * 2,
  //                 ),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     SizedBox(
  //                       height: MediaQuery.of(context).size.height * 0.10,
  //                     ),
  //                     monoVarifyText(),
  //                     otpText(),
  //                     mobText(),
  //                     otpLayout(),
  //                     verifyBtn(),
  //                     resendText(),
  //                     SizedBox(
  //                       height: MediaQuery.of(context).size.height * 0.10,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget getLogo() {
    return Center(
      child: Center(
        child: Image.asset(
          'assets/images/forgot_password.png',
          alignment: Alignment.center,
          scale: 2,

          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
