import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Screen/SignInUpAcc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Helper/Color.dart';
import 'Login.dart';

class IntroSlider extends StatefulWidget {
  const IntroSlider({Key? key}) : super(key: key);

  @override
  _GettingStartedScreenState createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<IntroSlider>
    with TickerProviderStateMixin {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  late List slideList = [];

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.initState();

    Future.delayed(Duration.zero, () {
      setState(() {});
    });

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.9,
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
    super.dispose();
    _pageController.dispose();
    buttonController!.dispose();

    // SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  _onPageChanged(int index) {
    if (mounted) {
      setState(() {
        _currentPage = index;
      });
    }
  }

  List<T?> map<T>(List list, Function handler) {
    List<T?> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  Widget _slider() {
    return Expanded(
      child: PageView.builder(
        itemCount: slideList.length,
        scrollDirection: Axis.horizontal,
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemBuilder: (BuildContext context, int index) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  getImages(index) ,
                 getTitle(index) ,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getTitle(int index) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              margin: const EdgeInsetsDirectional.only(
                  top: 20.0, ),
              child: Text(slideList[index].title,
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.bold))),
          Container(
            padding: const EdgeInsetsDirectional.only(
                top: 10.0, start: 10.0,end: 10.0),
            child: Text(slideList[index].description,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.normal,
                    fontSize: textFontSize14)),
          )
        ],
      ),
    );
  }

  Widget getImages(int index) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Image.asset(
        slideList[index].imageUrl,
      ),
    );
  }

  _btn() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: getList()),
          Center(
              child: Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 18.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: CupertinoButton(
                child: Container(
                  width: MediaQuery.of(context).size.width*0.7,
                  height: 55,
                  alignment: FractionalOffset.center,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            const Color(0xFF089BF0),
                            const Color(0xFF76B9D1),
                          ],
                          begin: const FractionalOffset(0.0, 0.0),
                          end: const FractionalOffset(1.0, 0.0),
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp),
                      borderRadius: BorderRadius.circular(10)),
                  child: _currentPage == 0 || _currentPage == 1
                      ? Text(
                          getTranslated(context, 'NEXT_LBL')!,
                          style: const TextStyle(color: colors.whiteTemp),
                        )
                      : Text(
                          getTranslated(context, 'GET_STARTED')!,
                          style: const TextStyle(color: colors.whiteTemp),
                        ),
                ),
                onPressed: () {
                  if (_currentPage == 2) {
                    setPrefrenceBool(ISFIRSTTIME, true);
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const Login()),
                    );
                  } else {
                    _currentPage = _currentPage + 1;
                    _pageController.animateToPage(_currentPage,
                        curve: Curves.decelerate,
                        duration: const Duration(milliseconds: 300));
                  }
                },
              ),
            )
            /*AppBtn(
                title: _currentPage == 0 || _currentPage == 1
                    ? getTranslated(context, 'NEXT_LBL')
                    : getTranslated(context, 'GET_STARTED'),
                btnAnim: buttonSqueezeanimation,
                btnCntrl: buttonController,
                onBtnSelected: () {
                  if (_currentPage == 2) {
                    setPrefrenceBool(ISFIRSTTIME, true);
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(builder: (context) => SignInUpAcc()),
                    );
                  } else {
                    _currentPage = _currentPage + 1;
                    _pageController.animateToPage(_currentPage,
                        curve: Curves.decelerate,
                        duration: Duration(milliseconds: 300));
                  }
                })*/
            ,
          )),
        ],
      ),
    );
  }

  List<Widget> getList() {
    List<Widget> childs = [];

    for (int i = 0; i < slideList.length; i++) {
      childs.add(AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _currentPage == i ? 20.0 : 10.0,
        height: 10,
        margin: const EdgeInsets.symmetric(horizontal: 3.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,

          color: _currentPage == i
              ? Color(0xff2A76F2)
              : Theme.of(context).colorScheme.fontColor.withOpacity((0.5)),
        ),
      ));
    }
    return childs;
  }

  skipBtn() {
    return _currentPage == 0 || _currentPage == 1
        ? Padding(
            padding: const EdgeInsetsDirectional.only(top: 20.0, end: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    setPrefrenceBool(ISFIRSTTIME, true);
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const SignInUpAcc()),
                    );
                  },
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(getTranslated(context, 'SKIP')!,
                          style: TextStyle(color: Colors.blue,fontSize: 17,fontWeight: FontWeight.bold)),
                    ),

                  ]),
                ),
              ],
            ))
        : Container(
            margin: const EdgeInsetsDirectional.only(top: 50.0),
            height: 15,
          );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    // SystemChrome.setEnabledSystemUIOverlays([]);

    slideList = [
      Slide(
        imageUrl: 'assets/images/introimage_a.png',
        title: getTranslated(context, 'TITLE1_LBL'),
        description: getTranslated(context, 'DISCRIPTION1'),
      ),
      Slide(
        imageUrl: 'assets/images/introimage_b.png',
        title: getTranslated(context, 'TITLE2_LBL'),
        description: getTranslated(context, 'DISCRIPTION2'),
      ),
      Slide(
        imageUrl: 'assets/images/introimage_c.png',
        title: getTranslated(context, 'TITLE3_LBL'),
        description: getTranslated(context, 'DISCRIPTION3'),
      ),
    ];

    return Scaffold(
        body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          skipBtn(),
          _slider(),
          _btn(),
        ],
      ),
    ));
  }
}

class Slide {
  final String imageUrl;
  final String? title;
  final String? description;

  Slide({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}
