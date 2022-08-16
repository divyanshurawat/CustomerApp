import 'dart:async';
import 'dart:convert';
import 'package:eshop_multivendor/Helper/call_button.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Screen/MyOrder.dart';
import 'package:eshop_multivendor/widgets/product_details_new.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/PushNotificationService.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/HomeProvider.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Screen/Favorite.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:eshop_multivendor/Screen/MyProfile.dart';
import 'package:eshop_multivendor/Screen/explore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../Provider/UserProvider.dart';
import 'All_Category.dart';
import 'Cart.dart';
import 'HomePage.dart';
import 'NotificationLIst.dart';
import 'Search.dart';

class Dashboard extends StatefulWidget {
  final int? sentIndex;
  final bool? userUpdate;
 Dashboard({Key? key,this.sentIndex,this.userUpdate}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Dashboard> with TickerProviderStateMixin {
  int _selBottom = 0;
  late TabController _tabController;
  bool _isNetworkAvail = true;

  late StreamSubscription streamSubscription;

 // late AnimationController navigationContainerAnimationController =
 //     AnimationController(
 //   vsync: this, // the SingleTickerProviderStateMixin
 //   duration: const Duration(milliseconds: 200),
  //);

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));



    initDynamicLinks();
    _tabController = TabController(
      length: 5,
      vsync: this,
    );

    if(widget.sentIndex!=null){
    //  print("### ${widget.sentIndex}");

         _tabController.animateTo(widget.sentIndex!);



    }
    //_tabController.animateTo(2);
    final pushNotificationService = PushNotificationService(
        context: context, tabController: _tabController);
    pushNotificationService.initialise();

    _tabController.addListener(
      () {
        Future.delayed(const Duration(seconds: 0)).then(
          (value) {},
        );

          setState(
                () {
              _selBottom = _tabController.index;
            },
          );


        if (_tabController.index == 3) {
          cartTotalClear();
        }
      },
    );

 //   Future.delayed(Duration.zero, () {
 //     context.read<HomeProvider>()
 //       ..setAnimationController(navigationContainerAnimationController)  ;
       // ..setBottomBarOffsetToAnimateController(
       //     navigationContainerAnimationController)
       // ..setAppBarOffsetToAnimateController(
       //     navigationContainerAnimationController);
  //  });
    super.initState();
  }

  void initDynamicLinks() async {
    streamSubscription = FirebaseDynamicLinks.instance.onLink.listen((event) {
      final Uri deepLink = event.link;
      if (deepLink.queryParameters.isNotEmpty) {
        int index = int.parse(deepLink.queryParameters['index']!);

        int secPos = int.parse(deepLink.queryParameters['secPos']!);

        String? id = deepLink.queryParameters['id'];

        String? list = deepLink.queryParameters['list'];

        getProduct(id!, index, secPos, list == 'true' ? true : false);
      }
    });

    /* FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;

      if (deepLink != null) {
        if (deepLink.queryParameters.length > 0) {
          int index = int.parse(deepLink.queryParameters['index']!);

          int secPos = int.parse(deepLink.queryParameters['secPos']!);

          String? id = deepLink.queryParameters['id'];

          String? list = deepLink.queryParameters['list'];

          getProduct(id!, index, secPos, list == "true" ? true : false);
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print(e.message);
    });
*/
    /*  final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      if (deepLink.queryParameters.length > 0) {
        int index = int.parse(deepLink.queryParameters['index']!);

        int secPos = int.parse(deepLink.queryParameters['secPos']!);

        String? id = deepLink.queryParameters['id'];

        // String list = deepLink.queryParameters['list'];

        getProduct(id!, index, secPos, true);
      }
    }*/
  }

  Future<void> getProduct(String id, int index, int secPos, bool list) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if(CUR_USERID!=null) {
        try {
          var parameter = {
            ID: id,
          };

          // if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
          Response response =
          await post(getProductApi, headers: headers, body: parameter)
              .timeout(const Duration(seconds: timeOut));

          var getdata = json.decode(response.body);
          bool error = getdata['error'];
          String msg = getdata['message'];
          if (!error) {
            var data = getdata['data'];

            List<Product> items = [];

            items =
                (data as List).map((data) => Product.fromJson(data)).toList();

            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) =>
                    ProductDetail1(
                      index: list ? int.parse(id) : index,
                      model: list
                          ? items[0]
                          : sectionList[secPos].productList![index],
                      secPos: secPos,
                      list: list,
                      indexPage: _selBottom,
                    )));
          } else {
            if (msg != 'Products Not Found !') setSnackbar(msg, context);
          }
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
        }
      }else{
        if (mounted) {
          setState(() {

          });
          Future.delayed(const Duration(seconds: 1)).then((_) {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const Login()),
            );
          });
        }
      }
    } else {
      {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_tabController.index != 0) {
          _tabController.animateTo(0);
          return false;
        }
        return true;
      },

      child:  Scaffold(

              floatingActionButton: FloatingActionButton(onPressed: () {
                call_button();
              },
                child: Image.asset("assets/images/contact.png"),
                backgroundColor: colors.primary,

              ),
              extendBodyBehindAppBar: false,
              extendBody: false,
              backgroundColor: Theme.of(context).colorScheme.lightWhite,
              appBar:_selBottom==2?const PreferredSize(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(""),
              ), preferredSize: Size.fromHeight(10.0)):_getAppBar()
              ,
              body: SafeArea(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    HomePage(),
                    const AllCategory(),
                    //Sale(),
                    const MyOrder(fromDashboard: true,),
                    Cart(
                      fromBottom: true,
                    ),
                    MyProfile(
                      userUpdate: widget.userUpdate,
                    ),
                  ],
                ),

                /*Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child:
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(height: 70, child: _getBottomBar())),
              */
                /*  Align(
                alignment: Alignment.topCenter,
                child: _getAppBar()
              ),*/ /*
              */ /*
              Align(
               alignment: Alignment.bottomCenter,
                child: _getBottomBar(),
              )*/ /*
            ],
          ),*/
              ),
              bottomNavigationBar: _getBottomBar(),


      ),
    );
  }

  _getAppBar() {
    String? title;
    if (_selBottom == 1) {
      title = getTranslated(context, 'CATEGORY');
    } else if (_selBottom == 2) {
      title = getTranslated(context, 'EXPLORE');
    } else if (_selBottom == 3) {
      title = getTranslated(context, 'MYBAG');
    } else if (_selBottom == 4) {

      title = getTranslated(context, 'PROFILE');
    }
    final appBar = AppBar(

automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: false,
      backgroundColor: colors.primary,
      title:_selBottom == 4?Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 20, 0),
        child: Text("Account",style: TextStyle(color: Colors.white),),
      ): _selBottom == 0 ||_selBottom == 1
          ? Container(
        color: colors.primary,
        //data == Brightness.light ?Color(0xffEEF2F9) :  Color(0xff181616),
        padding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
        child: GestureDetector(
          child: SizedBox(

            height: 35,
            child: TextField(
              enabled: false,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.lightWhite),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 0, 0.0),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                  isDense: true,
                  hintText: getTranslated(context, 'searchHint'),
                  hintStyle: Theme.of(context).textTheme.bodyText2!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontSize: textFontSize16,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                  ),
                  prefixIcon: const Padding(
                      padding: EdgeInsets.all(5.0), child: Icon(Icons.search,size: 28,)),

                  fillColor: Theme.of(context).colorScheme.white,
                  filled: true),
            ),
          ),
          onTap: () async {
            //showOverlaySnackBar(context, Colors.amber, "message",50 );
            await Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const Search(),
                ));
          },
        ),
      )
          : _selBottom==3?Text(
        "Cart",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      ):Text(
              title!,
              style: const TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.normal,
              ),
            ),


      actions: <Widget>[

        _selBottom == 2 ||_selBottom == 4?Text(""):   Padding(
          padding: const EdgeInsetsDirectional.only(
              end: 10.0, bottom: 5.0, top: 5.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(circularBorderRadius10),
              color: colors.primary,
            ),
            width: 40,
            child: IconButton(
              icon: SvgPicture.asset('${imagePath}fav_black.svg',
                  color: Theme.of(context)
                      .colorScheme
                      .white // Add your color here to apply your own color
                  ),
              onPressed: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const Favorite(),
                    ));
              },
            ),
          ),
        ),
        _selBottom == 2 ||_selBottom == 4?Text(""):    Padding(
          padding: const EdgeInsetsDirectional.only(
              end: 10.0, bottom: 5.0, top: 5.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(circularBorderRadius10),
              color: colors.primary,
            ),
            width: 30,
            child: IconButton(
              icon: SvgPicture.asset(
                '${imagePath}notification_black.svg',
                color: Theme.of(context)
                    .colorScheme
                    .white, // Add your color here to apply your own color
              ),
              onPressed: () {
                CUR_USERID != null
                    ? Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const NotificationList(),
                        )).then((value) {
                        if (value != null && value) {
                          _tabController.animateTo(1);
                        }
                      })
                    : Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const Login(),
                        ));
              },
            ),
          ),
        ),
      ],
    );

    /*return PreferredSize(
      preferredSize: appBar.preferredSize,
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: context.watch<HomeProvider>().getBars ? 100 :0,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.white,
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).colorScheme.black26,
                  blurRadius: 10)
            ],
          ),
          child: appBar),
    );*/
    return PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: SizedBox(
            height: context.watch<HomeProvider>().getBars ? 130 : 0,
            child: appBar));
    return SlideTransition(
      position: context.watch<HomeProvider>().animationAppBarBarOffset,
      child: Container(
        height: 75,
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        child: Row(),
      ),
    );
  }

  getTab(String enabledImage, String disabledImage, int selectedIndex,
      String name){
    return  Selector<UserProvider, String>(
      builder: (context, data, child) {
        return IconButton(
          icon: Stack(
            children: [
              Wrap(
                children: [

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 25,
                        child: _selBottom == selectedIndex
                            ? Image.asset(imagePath + disabledImage,
                          height: 35,color: colors.primary,)
                            : Image.asset(imagePath + disabledImage,
                            color: Colors.grey, height: 20),
                      ),
                      Text(getTranslated(context, name)!,
                          style: TextStyle(
                              color: _selBottom == selectedIndex
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.lightBlack,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 9.0),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          )
                    ],
                  ),
                ],
              ),

              (data.isNotEmpty && data != '0')
                  ? Positioned(
                bottom: 18,
                right: 0,
                top: 0,
                child: Container(
                  //  height: 20,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.red),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Text(
                        data,
                        style: const TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: colors.whiteTemp),
                      ),
                    ),
                  ),
                ),
              )
                  : Container()
            ],
          ),
          onPressed: () {
           // cartTotalClear();
            _tabController.animateTo(3)  ;
          //  Navigator.push(
          //    context,
          //    CupertinoPageRoute(
          //      builder: (context) => const Cart(
          //        fromBottom: false,
          //      ),
          //    ),
          //  );
          },
        );
      },
      selector: (_, homeProvider) => homeProvider.curCartCount,
    );
  }
  getTabOrder(String enabledImage, String disabledImage, int selectedIndex,
      String name) {
    return IconButton(
      onPressed: (){
        _tabController.animateTo(selectedIndex);
      //  Navigator.push(context, MaterialPageRoute(builder: (context)=>MyOrder()));

      },
      icon:  Wrap(
        children: [

          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 22,
                child: _selBottom == selectedIndex
                    ? Image.asset(imagePath + disabledImage,
                  height: 20,color: colors.primary,)
                    : Image.asset(imagePath + disabledImage,
                    color: Colors.grey, height: 0),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(getTranslated(context, name)!,
                    style: TextStyle(
                        color: _selBottom == selectedIndex
                            ? Theme.of(context).colorScheme.fontColor
                            : Theme.of(context).colorScheme.lightBlack,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 9.0),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                   ),
              )
            ],
          ),
        ],
      ),
    );
  }
  getTabItem(String enabledImage, String disabledImage, int selectedIndex,
      String name) {
    return Wrap(
      children: [

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: SizedBox(
                height: 25,
                child: _selBottom == selectedIndex
                    ? Image.asset(imagePath + disabledImage,
                        height: 25,color: colors.primary,)
                    : Image.asset(imagePath + disabledImage,
                        color: Colors.grey, height: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(getTranslated(context, name)!,
                  style: TextStyle(
                      color: _selBottom == selectedIndex
                          ? Theme.of(context).colorScheme.fontColor
                          : Theme.of(context).colorScheme.lightBlack,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 9.0),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                 ),
            )
          ],
        ),
      ],
    );
  }

  Widget _getBottomBar() {
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;

    return Container(
      height: context.watch<HomeProvider>().getBars
          ? kBottomNavigationBarHeight
          : 0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.white,
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).colorScheme.black26, blurRadius: 5)
        ],
      ),
      child: Selector<ThemeNotifier, ThemeMode>(
          selector: (_, themeProvider) => themeProvider.getThemeMode(),
          builder: (context, data, child) {
            return TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: getTabItem(
                      '1',
                      'home.png',
                      0,
                      'HOME_LBL'),
                ),
                Tab(
                  child: getTabItem(
                      '1',
                      'product.png',
                      1,
                      'CATEGORY'),
                ),
                Tab(
                  child: getTabOrder(
                      '1',
                      'orders.png',
                      2,
                      'EXPLORE'),
                ),
                Tab(
                  child: getTab(
                      '1',
                      'cart.png',
                      3,
                      'CART'),
                ),

                // Tab(
                //     child: Selector<UserProvider, String>(
                //       builder: (context, data, child) {
                //         return Wrap(
                //           children: [
                //             Stack(
                //               alignment: Alignment.center,
                //               children: [
                //                 Column(
                //                   children: [
                //                     _selBottom == 3
                //                         ? Lottie.asset(
                //                         (data == ThemeMode.system && currentBrightness == Brightness.dark)  || data == ThemeMode.dark
                //                             ? 'assets/animation/dark_active_cart.json'
                //                             : 'assets/animation/light_active_cart.json',
                //                         repeat: false,
                //                         height: 20)
                //                         : SvgPicture.asset(imagePath + 'cart.svg',
                //                         color: Colors.grey, height: 20),
                //                     // Categories
                //                     Padding(
                //                       padding:
                //                       const EdgeInsets.symmetric(vertical: 4.0),
                //                       child: Text(getTranslated(context, 'CART')!,
                //                           style: const TextStyle(
                //                               color: Colors.grey,
                //                               fontWeight: FontWeight.w400,
                //                               fontStyle: FontStyle.normal,
                //                               fontSize: textFontSize10),
                //                           textAlign: TextAlign.center,
                //                           maxLines: 1,
                //                           overflow: TextOverflow.ellipsis),
                //                     )
                //                   ],
                //                 ),
                //               ],
                //             ),
                //           ],
                //         );
                //       },
                //       selector: (_, homeProvider) => homeProvider.curCartCount,
                //     )),
                Tab(
                  child: getTabItem(
                      '1',
                      'profile.png',
                      4,
                      'PROFILE'),
                ),
              ],
              indicatorColor: Colors.transparent,
              labelColor: colors.primary,
              labelStyle: const TextStyle(fontSize: textFontSize12),
            );
          }),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
