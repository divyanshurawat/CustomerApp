import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Color.dart';

class AppBtn extends StatelessWidget {
  final String? title;
  final AnimationController? btnCntrl;
  final Animation? btnAnim;
  final VoidCallback? onBtnSelected;

  const AppBtn(
      {Key? key, this.title, this.btnCntrl, this.btnAnim, this.onBtnSelected})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildBtnAnimation,
      animation: btnCntrl!,
    );
  }



  Widget _buildBtnAnimation(BuildContext context, Widget? child) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: CupertinoButton(
        child: Container(
          width: btnAnim!.value,
          height: 45,

          alignment: FractionalOffset.center,
          decoration:  BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2A76F2),
                    const Color(0xFFA2B6E2),
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
              borderRadius: BorderRadius.circular(10)),
          child: btnAnim!.value > 75.0
              ? Text(title!,
              textAlign: TextAlign.center,
              style: Theme
                  .of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: colors.whiteTemp, fontWeight: FontWeight.normal))
              : const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colors.whiteTemp),
          ),
        ),

        onPressed: () {
          onBtnSelected!();
        },
      ),
    );
  }

}
