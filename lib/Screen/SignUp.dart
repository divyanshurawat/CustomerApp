import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/cropped_container.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../Helper/ApiBaseHelper.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../main.dart';
import 'HomePage.dart';
import 'Verify_Otp.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUp> with TickerProviderStateMixin {
  bool? _showPassword = false;
  bool visible = false;
  String? imageLink = "";
  int? selectLan;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final adhaarController = TextEditingController();

  final gstController = TextEditingController();

  final ccodeController = TextEditingController();
  final passwordController = TextEditingController();
  final referController = TextEditingController();
  int count = 1;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  List<String?> languageList = [];
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  List<String> langCode = [
    'en',
    'zh',
    'es',
    'fr',
    'hi',
    'ar',
    'ru',
    'ja',
    'de'
  ];
  String? name,
      email,
      password,
      mobile,
      id,
      countrycode ="91",
      city,
  countryName,
      area,
      pincode,
      address,
  gstno,
  aadhar,
     latitude,
      longitude,
      referCode,
      friendCode;
  FocusNode? nameFocus,
      emailFocus,
  addressFocus,
  adhaarFocus,
  gstFocus,

      passFocus = FocusNode(),
      referFocus = FocusNode();
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;

  AnimationController? buttonController;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }
  Future<void> getVerifyUser() async {
    try {
      var data = {MOBILE: mobile};
      Response response =
      await post(getVerifyUserApi, body: data, headers: headers)
          .timeout(const Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool? error = getdata['error'];
      String? msg = getdata['message'];
      await buttonController!.reverse();
      print(getdata);

      SettingProvider settingsProvider =
      Provider.of<SettingProvider>(context, listen: false);

        if (!error!) {
      if(countrycode!=null) {
     Future.delayed(const Duration(seconds: 1)).then((_) {
  Navigator.pushReplacement(
   context,
   CupertinoPageRoute(
       builder: (context) =>
           VerifyOtp(
             mobileNumber: mobile!,
             countryCode: countrycode,
             name: name,
             email: email,
             mobile: mobile,
             countrycode: countrycode,
             friendCode: friendCode,
             referCode: referCode,
             gstno: gstno,
             aadhaar: aadhar,
             address: address,
             password: password,
             title: getTranslated(context, 'SEND_OTP_TITLE'),
           )));
  });
}else{
  Future.delayed(const Duration(seconds: 1)).then((_) {
    Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
            builder: (context) =>
                VerifyOtp(
                  mobileNumber: mobile!,
                  countryCode: '91',

                  name: name,
                  email: email,
                  mobile: mobile,
                  countrycode: countrycode,
                  friendCode: friendCode,
                  referCode: referCode,
                  gstno: '',
                  aadhaar: aadhar,
                  address: address,
                  password: password,


                  title: getTranslated(context, 'SEND_OTP_TITLE'),
                )));
  });
}
       // } else {
         // setSnackbar(msg!, context);
       // }
      }
     // if (widget.title == getTranslated(context, 'FORGOT_PASS_TITLE')) {
       // if (error!) {
          settingsProvider.setPrefrence(MOBILE, mobile!);
          settingsProvider.setPrefrence(COUNTRY_CODE, countrycode!);

        //  getRegisterUser();
        //  Future.delayed(const Duration(seconds: 1)).then((_) {
        //    Navigator.pushReplacement(
        //        context,
        //        CupertinoPageRoute(
        //            builder: (context) => VerifyOtp(
        //              mobileNumber: mobile!,
        //              countryCode: countrycode,
        //              title: getTranslated(context, 'FORGOT_PASS_TITLE'),
        //            )));
        //  });
      //  } else {
      //    setSnackbar(getTranslated(context, 'FIRSTSIGNUP_MSG')!, context);
       // }
      //}
    } on TimeoutException catch (_) {
    //  setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      await buttonController!.reverse();
    }
  }

  void getSlider() {
    Map map = {};

    apiBaseHelper.postAPICall(getMainApi, map).then((getdata) {
      bool error = getdata['error'];
      String? msg = getdata['message'];
      if (!error) {
        var data = getdata['data'];
        print(data[0]['image']);
        setState(() {
          imageLink = data[0]['image'];
        });

        //homeSliderList =
        //    (data as List).map((data) => Model.fromSlider(data)).toList();

        //pages = homeSliderList.map((slider) {
        //  return _buildImagePageItem(slider);
        //}).toList();
      } else {
        //  setSnackbar(msg!, context);
      }

      // context.read<HomeProvider>().setSliderLoading(false);
    }, onError: (error) {
      // setSnackbar(error.toString(), context);
      // context.read<HomeProvider>().setSliderLoading(false);
    });
  }

  getUserDetails() async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);

    mobile = await settingsProvider.getPrefrence(MOBILE);
    countrycode = await settingsProvider.getPrefrence(COUNTRY_CODE);
    if (mounted) setState(() {});
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
    //  setSnackbar(msg!, context);


      var i = getdata['data'][0];
      id = i[ID];
     // username = i[USERNAME];
      email = i[EMAIL];
      mobile = i[MOBILE];
      city = i[CITY];
      area = i[AREA];
      address = i[ADDRESS];
      pincode = i[PINCODE];
      latitude = i[LATITUDE];
      longitude = i[LONGITUDE];
     // image = i[IMAGE];
      //active = i[ACTIVE];
      gstno= i[GSTNO];
      aadhar=i[AADHAAR];

      CUR_USERID = id;
      // CUR_USERNAME = username;
     // print(active);
      UserProvider userProvider =
      Provider.of<UserProvider>(context, listen: false);
      userProvider.setName(mobile ?? '');
      userProvider.setEmail(email ?? '');
     // userProvider.setProfilePic(image ?? '');

      SettingProvider settingProvider =
      Provider.of<SettingProvider>(context, listen: false);

      settingProvider.saveUserDetail(id!, mobile, email, mobile, city, area,gstno,aadhar,
          address, pincode, latitude, longitude, '', context);


      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);


    } else {

     print(msg!);
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

  Widget bottomSheetHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Theme.of(context).colorScheme.lightBlack),
        height: 5,
        width: MediaQuery.of(context).size.width * 0.3,
      ),
    );
  }
  Widget bottomsheetLabel(String labelName) => Padding(
    padding: const EdgeInsets.only(top: 30.0, bottom: 20),
    child: getHeading(labelName),
  );

  Widget setCodeWithMono() {
    return Padding(
      padding: const EdgeInsets.only(top: 17),
      child: Container(
          height: 53,
          width: double.maxFinite,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.lightWhite,
              borderRadius: BorderRadius.circular(10.0)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: setCountryCode(),
              ),
              Expanded(
                flex: 4,
                child: setMono(),
              )
            ],
          )),
    );
  }

  Widget setCountryCode() {
    double width = deviceWidth!;
    double height = deviceHeight! * 0.9;
    return CountryCodePicker(
        showCountryOnly: false,
        searchStyle: TextStyle(
          color: Theme.of(context).colorScheme.fontColor,
        ),
        flagWidth: 20,
        boxDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
        ),
        searchDecoration: InputDecoration(
          hintText: getTranslated(context, 'COUNTRY_CODE_LBL'),
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.fontColor),
          fillColor: Theme.of(context).colorScheme.fontColor,
        ),
        showOnlyCountryWhenClosed: false,
        initialSelection: 'IN',
        dialogSize: Size(width, height),
        alignLeft: true,
        textStyle: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.bold),
        onChanged: (CountryCode countryCode) {
          countrycode = countryCode.toString().replaceFirst('+', '');
          countryName = countryCode.name;
        },
        onInit: (code) {
          countrycode = code.toString().replaceFirst('+', '');
        });
  }

  Widget setMono() {
    return TextFormField(
        keyboardType: TextInputType.number,
        controller: mobileController,

        style: Theme.of(context).textTheme.subtitle2!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (val) => validateMob(
            val!,
            getTranslated(context, 'MOB_REQUIRED'),
            getTranslated(context, 'VALID_MOB')),
        onSaved: (String? value) {
          mobile = value;
        },
        decoration: InputDecoration(
          hintText: getTranslated(context, 'MOBILEHINT_LBL'),
          hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          //  focusedBorder: OutlineInputBorder(
          //    borderSide: BorderSide(color: Theme.of(context).colorScheme.lightWhite),
          //  ),
          focusedBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          border: InputBorder.none,
          enabledBorder: UnderlineInputBorder(
            borderSide:
            BorderSide(color: Theme.of(context).colorScheme.lightWhite),
          ),
        ));
  }


  Widget getHeading(String title) {
    return Text(
      getTranslated(context, title)!,
      style: Theme.of(context).textTheme.headline6!.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
  List<Widget> getLngList(BuildContext ctx, StateSetter setModalState) {
    return languageList
        .asMap()
        .map(
          (index, element) => MapEntry(
        index,
        InkWell(
          onTap: () {
            if (mounted) {
              setState(() {
                selectLan = index;
                _changeLan(langCode[index], ctx);
              });
            }
            setModalState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 25.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectLan == index
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          border: Border.all(color: colors.grad2Color)),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: selectLan == index
                            ? Icon(
                          Icons.check,
                          size: 17.0,
                          color:
                          Theme.of(context).colorScheme.fontColor,
                        )
                            : Icon(
                          Icons.check_box_outline_blank,
                          size: 15.0,
                          color: Theme.of(context).colorScheme.white,
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 15.0,
                        ),
                        child: Text(
                          languageList[index]!,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .lightBlack),
                        ))
                  ],
                ),
                // index == languageList.length - 1
                //     ? Container(
                //         margin: EdgeInsetsDirectional.only(
                //           bottom: 10,
                //         ),
                //       )
                //     : Divider(
                //         color: Theme.of(context).colorScheme.lightBlack,
                //       ),
              ],
            ),
          ),
        ),
      ),
    )
        .values
        .toList();
  }

  void _changeLan(String language, BuildContext ctx) async {
    Locale locale = await setLocale(language);

    MyApp.setLocale(ctx, locale);
  }

  void openChangeLanguageBottomSheet() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0))),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  bottomSheetHandle(),
                  bottomsheetLabel('CHOOSE_LANGUAGE_LBL'),
                  StatefulBuilder(
                    builder:
                        (BuildContext context, StateSetter setModalState) {
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: getLngList(
                            context,
                            setModalState,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      if (referCode != null) getVerifyUser();
    } else {
      Future.delayed(const Duration(seconds: 2)).then((_) async {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
        await buttonController!.reverse();
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

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    buttonController!.dispose();
    super.dispose();
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
      ),
      elevation: 1.0,
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
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
                      if (mounted) setState(() {});
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



  Widget registerTxt() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(top: 5.0),
        child: Align(
          alignment: Alignment.center,
          child: Text(getTranslated(context, 'Create a new account')!,
              style: Theme.of(context).textTheme.headline6!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                  letterSpacing: 0.8)),
        ));
  }

  signUpSubTxt() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(
          top: 13.0,
        ),
        child: Text(
          getTranslated(context, 'INFO_FOR_NEW_ACCOUNT')!,
          style: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold),
        ));
  }

  setUserName() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Container(
        height: 53,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.lightWhite,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: TextFormField(
          //initialValue: nameController.text,
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 13),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.words,
          controller: nameController,
          focusNode: nameFocus,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 5,
              ),
              hintText: getTranslated(context, 'NAMEHINT_LBL'),
              hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              fillColor: Theme.of(context).colorScheme.lightWhite,
              border: InputBorder.none),
          validator: (val) => validateUserName(
              val!,
              getTranslated(context, 'USER_REQUIRED'),
              getTranslated(context, 'USER_LENGTH')),
          onSaved: (String? value) {
            name = value;
          },
          onFieldSubmitted: (v) {
            _fieldFocusChange(context, nameFocus!, emailFocus);
          },
        ),
      ),
    );
  }

  /* setUserName() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 15.0,
        end: 15.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.words,
        controller: nameController,
        focusNode: nameFocus,
        textInputAction: TextInputAction.next,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        validator: (val) => validateUserName(
            val!,
            getTranslated(context, 'USER_REQUIRED'),
            getTranslated(context, 'USER_LENGTH')),
        onSaved: (String? value) {
          name = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, nameFocus!, emailFocus);
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.account_circle_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'NAMEHINT_LBL'),
          hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          // filled: true,
          // fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, maxHeight: 25),
          // focusedBorder: OutlineInputBorder(
          //   borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
          //   borderRadius: BorderRadius.circular(10.0),
          // ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }*/
  setAddress() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        height: 53,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.lightWhite,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: TextFormField(
          //initialValue: nameController.text,
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 13),
          keyboardType: TextInputType.name,
          maxLines: 2,
          focusNode: addressFocus,
          textInputAction: TextInputAction.next,
          controller: addressController,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 5,
              ),
              hintText: "Address",
              hintStyle: TextStyle(
                  color:
                  Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              fillColor: Theme.of(context).colorScheme.lightWhite,
              border: InputBorder.none),
          validator: (val) => validateAddress(
              val!,
              "Address Required",
             "Please enter full address"),
          onSaved: (String? value) {
            address = value;
          },
          onFieldSubmitted: (v) {
            _fieldFocusChange(context, addressFocus!, passFocus);
          },
        ),
      ),
    );
  }
  setAadhaar() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        height: 53,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.lightWhite,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: TextFormField(
          //initialValue: nameController.text,
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 13),
          keyboardType: TextInputType.name,
          maxLines: 2,
          focusNode: adhaarFocus,
          textInputAction: TextInputAction.next,
          controller: adhaarController,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 5,
              ),
              hintText: "Aadhaar (Optional)",
              hintStyle: TextStyle(
                  color:
                  Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              fillColor: Theme.of(context).colorScheme.lightWhite,
              border: InputBorder.none),

          onSaved: (String? value) {
            aadhar = value;
          },
          onFieldSubmitted: (v) {
            _fieldFocusChange(context, adhaarFocus!, passFocus);
          },
        ),
      ),
    );
  }
  setGstno() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        height: 53,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.lightWhite,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: TextFormField(
          //initialValue: nameController.text,
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 13),
          keyboardType: TextInputType.name,
          maxLines: 2,
          focusNode: gstFocus,
          textInputAction: TextInputAction.next,
          controller: gstController,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 5,
              ),
              hintText: "GST No. (Optional)",
              hintStyle: TextStyle(
                  color:
                  Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              fillColor: Theme.of(context).colorScheme.lightWhite,
              border: InputBorder.none),
          validator: (val) => validateGST(
              val!,
              "Enter Gst no.",
              "Please enter gst no."),
          onSaved: (String? value) {
            gstno = value;
          },
          onFieldSubmitted: (v) {
            _fieldFocusChange(context, gstFocus!, passFocus);
          },
        ),
      ),
    );
  }
  setEmail() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        height: 53,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.lightWhite,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: TextFormField(
          //initialValue: nameController.text,
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 13),
          keyboardType: TextInputType.emailAddress,
          focusNode: emailFocus,
          textInputAction: TextInputAction.next,
          controller: emailController,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 5,
              ),
              hintText: getTranslated(context, 'EMAILHINT_LBL'),
              hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              fillColor: Theme.of(context).colorScheme.lightWhite,
              border: InputBorder.none),
         // validator: (val) => validateEmail(
         //     val!,
         //     getTranslated(context, 'EMAIL_REQUIRED'),
         //     getTranslated(context, 'VALID_EMAIL')),
          onSaved: (String? value) {
            email = value;
          },
          onFieldSubmitted: (v) {
            _fieldFocusChange(context, emailFocus!, passFocus);
          },
        ),
      ),
    );
  }

  /*setEmail() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 10.0,
        start: 15.0,
        end: 15.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        focusNode: emailFocus,
        textInputAction: TextInputAction.next,
        controller: emailController,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        validator: (val) => validateEmail(
            val!,
            getTranslated(context, 'EMAIL_REQUIRED'),
            getTranslated(context, 'VALID_EMAIL')),
        onSaved: (String? value) {
          email = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, emailFocus!, passFocus);
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.alternate_email_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'EMAILHINT_LBL'),
          hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          // filled: true,
          // fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, maxHeight: 25),
          // focusedBorder: OutlineInputBorder(
          //   borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
          //   borderRadius: BorderRadius.circular(10.0),
          // ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }*/

  setRefer() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Container(
        height: 53,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.lightWhite,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: TextFormField(
          //initialValue: nameController.text,
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 13),
          keyboardType: TextInputType.text,
          focusNode: referFocus,
          controller: referController,
          textInputAction: TextInputAction.done,

          onSaved: (String? value) {
            friendCode = value;
          },
          onFieldSubmitted: (v) {
            _fieldFocusChange(context, passFocus!, referFocus);
          },
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 5,
              ),
              hintText: getTranslated(context, 'REFER'),
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
  /* setRefer() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 10.0,
        start: 15.0,
        end: 15.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        focusNode: referFocus,
        controller: referController,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        onSaved: (String? value) {
          friendCode = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.card_giftcard_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'REFER'),
          hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          // filled: true,
          // fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, maxHeight: 25),
          // focusedBorder: OutlineInputBorder(
          //   borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
          //   borderRadius: BorderRadius.circular(10.0),
          // ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }*/

/*  setPass() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        height: 53,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.lightWhite,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: TextFormField(
          //initialValue: nameController.text,
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 13),
          keyboardType: TextInputType.emailAddress,
          focusNode: emailFocus,
          textInputAction: TextInputAction.next,
          controller: emailController,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 5,
              ),
              hintText: getTranslated(context, 'EMAILHINT_LBL'),
              hintStyle: TextStyle(
                  color:
                  Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              fillColor: Theme.of(context).colorScheme.lightWhite,
              border: InputBorder.none),
          validator: (val) => validateEmail(
              val!,
              getTranslated(context, 'EMAIL_REQUIRED'),
              getTranslated(context, 'VALID_EMAIL')),
          onSaved: (String? value) {
            email = value;
          },
          onFieldSubmitted: (v) {
            _fieldFocusChange(context, emailFocus!, passFocus);
          },
        ),
      ),
    );
  }*/

  setPass() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Container(
        height: 53,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.lightWhite,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: TextFormField(
          //initialValue: nameController.text,
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 13),
          keyboardType: TextInputType.text,
          obscureText: _showPassword!,
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
          onFieldSubmitted: (v) {
            _fieldFocusChange(context, passFocus!, referFocus);
          },
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 5,
              ),
              suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      _showPassword = !_showPassword!;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 10.0),
                    child: Icon(
                      _showPassword! ? Icons.visibility : Icons.visibility_off,
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

  /* setPass() {
    return Padding(
        padding:
            const EdgeInsetsDirectional.only(start: 15.0, end: 15.0, top: 10.0),
        child: TextFormField(
          keyboardType: TextInputType.text,
          obscureText: !_showPassword!,
          focusNode: passFocus,
          onFieldSubmitted: (v) {
            _fieldFocusChange(context, passFocus!, referFocus);
          },
          textInputAction: TextInputAction.next,
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          controller: passwordController,
          validator: (val) => validatePass(
              val!,
              getTranslated(context, 'PWD_REQUIRED'),
              getTranslated(context, 'PWD_LENGTH')),
          onSaved: (String? value) {
            password = value;
          },
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: const BorderSide(color: colors.primary),
              borderRadius: BorderRadius.circular(7.0),
            ),
            prefixIcon: SvgPicture.asset(
              'assets/images/password.svg',
              height: 17,
              width: 17,
              color: Theme.of(context).colorScheme.fontColor,
            ),
            // Icon(
            //   Icons.lock_outline,
            //   color: Theme.of(context).colorScheme.lightBlack2,
            //   size: 17,
            // ),
            hintText: getTranslated(context, 'PASSHINT_LBL'),
            hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal),
            // filled: true,
            // fillColor: Theme.of(context).colorScheme.lightWhite,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 40, maxHeight: 25),
            // focusedBorder: OutlineInputBorder(
            //   borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
            //   borderRadius: BorderRadius.circular(10.0),
            // ),
            enabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.fontColor),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ));
  }*/

  showPass() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 30.0,
          end: 30.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Checkbox(
              value: _showPassword,
              checkColor: Theme.of(context).colorScheme.fontColor,
              activeColor: Theme.of(context).colorScheme.lightWhite,
              onChanged: (bool? value) {
                if (mounted) {
                  setState(() {
                    _showPassword = value;
                  });
                }
              },
            ),
            Text(getTranslated(context, 'SHOW_PASSWORD')!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.normal))
          ],
        ));
  }

  verifyBtn() {
    return Center(
      child: AppBtn(
        title: getTranslated(context, 'SAVE_LBL'),
        btnAnim: buttonSqueezeanimation,
        btnCntrl: buttonController,
        onBtnSelected: () async {
          validateAndSubmit();
        },
      ),
    );
  }

  loginTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(getTranslated(context, 'ALREADY_A_CUSTOMER')!,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold)),
          InkWell(
              onTap: () {
                Navigator.of(context).push(CupertinoPageRoute(
                  builder: (BuildContext context) => const Login(),
                ));
              },
              child: Text(
                getTranslated(context, 'LOG_IN_LBL')!,
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ))
        ],
      ),
    );
  }

  /* loginTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 25.0,
        end: 25.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(getTranslated(context, 'ALREADY_A_CUSTOMER')!,
              style: Theme.of(context).textTheme.caption!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal)),
          InkWell(
              onTap: () {
                Navigator.of(context).push(CupertinoPageRoute(
                  builder: (BuildContext context) => const Login(),
                ));
              },
              child: Text(
                getTranslated(context, 'LOG_IN_LBL')!,
                style: Theme.of(context).textTheme.caption!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.normal),
              ))
        ],
      ),
    );
  }*/

  backBtn() {
    return Platform.isIOS
        ? Container(
            padding: const EdgeInsetsDirectional.only(top: 20.0, start: 10.0),
            alignment: AlignmentDirectional.topStart,
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 4.0),
                child: InkWell(
                  child: const Icon(Icons.keyboard_arrow_left,
                      color: colors.primary),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ))
        : Container();
  }

  expandedBottomView() {
    return Expanded(
        flex: 8,
        child: Container(
          alignment: Alignment.bottomCenter,
          child: Form(
            key: _formkey,
            child: Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsetsDirectional.only(
              start: 20.0, end: 20.0, top: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              registerTxt(),
              setUserName(),

              setEmail(),
              setPass(),
              setRefer(),
              //showPass(),
              verifyBtn(),
              loginTxt(),
            ],
          ),
            ),
          ),
        ));
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    super.initState();
    getSlider();
    getUserDetails();
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

    generateReferral();
  }

  @override
  Widget build(BuildContext context) {
    languageList = [
      getTranslated(context, 'ENGLISH_LAN'),
      getTranslated(context, 'CHINESE_LAN'),
      getTranslated(context, 'SPANISH_LAN'),
      getTranslated(context, 'FRENCH_LAN'),
      getTranslated(context, 'HINDI_LAN'),
      getTranslated(context, 'ARABIC_LAN'),
      getTranslated(context, 'RUSSIAN_LAN'),
      getTranslated(context, 'JAPANISE_LAN'),
      getTranslated(context, 'GERMAN_LAN')
    ];
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Theme.of(context).colorScheme.white,
          key: _scaffoldKey,
          body: _isNetworkAvail
              ? SingleChildScrollView(
                  child: Column(
                    children: [

                      getLogo(),
                      SingleChildScrollView(
                        padding: EdgeInsets.only(
                            top: 13,
                            left: 23,
                            right: 23,
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Form(
                          key: _formkey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              setUserName(),
                               setCodeWithMono(),
                              setEmail(),
                              setAddress(),
                              setAadhaar(),
                            //  setGstno(),
                              setPass(),
                              setRefer(),
                              //showPass(),
                              verifyBtn(),
                              loginTxt(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              /*  Column(
                  children: [
                    backBtn(),
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: back(),
                    ),
                    Image.asset(
                      'assets/images/doodle.png',
                      fit: BoxFit.fill,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    //getBgImage(),
                    getLoginContainer(),
                    getLogo(),
                  ],
                )*/
              : noInternet(context)),
    );
  }

  Future<void> generateReferral() async {
    String refer = getRandomString(8);

    try {
      var data = {
        REFERCODE: refer,
      };

      Response response =
          await post(validateReferalApi, body: data, headers: headers)
              .timeout(const Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata['error'];

      if (!error) {
        referCode = refer;
        REFER_CODE = refer;
        if (mounted) setState(() {});
      } else {
        if (count < 5) generateReferral();
        count++;
      }
    } on TimeoutException catch (_) {}
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

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
                    maxHeight: MediaQuery.of(context).size.height * 2.5,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      registerTxt(),
                      setUserName(),
                       setCodeWithMono(),
                      setEmail(),
                      setPass(),
                      setRefer(),
                      //showPass(),
                      verifyBtn(),
                      loginTxt(),
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
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(17),
              bottomRight: Radius.circular(17))),
      height: MediaQuery.of(context).size.height / 2.8,
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: 'https://i.ytimg.com/vi/mUgdzTWCkOc/maxresdefault.jpg',
            height: MediaQuery.of(context).size.height / 2.8,
            width: MediaQuery.of(context).size.width,

            imageBuilder: (context, imageProvider) => Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(17),
                      bottomRight: Radius.circular(17)),
                image: DecorationImage(
                    image: imageProvider, fit: BoxFit.cover),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Color(0xff1273ba),
                      borderRadius: BorderRadius.circular(20)),
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


                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: 25.0,
                  ),
                  child: Center(child: registerTxt()),
                ),
                signUpSubTxt(),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                  onPressed: (){
                    openChangeLanguageBottomSheet();
                  },
                  child: Text(getTranslated(context, 'CHANGE_LANGUAGE_LBL')!)),
            ],
          ),
        ],
      ),
    );
  }

  Widget signUpTxt() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(
          top: 40.0,
        ),
        child: Text(
          getTranslated(context, 'Sign up')!,
          style: Theme.of(context).textTheme.headline6!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontSize: 43,
              letterSpacing: 0.8),
        ));
  }
}
