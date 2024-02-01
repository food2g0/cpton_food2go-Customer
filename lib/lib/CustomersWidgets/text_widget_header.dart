import 'package:flutter/material.dart';



class TextWidgetHeader extends SliverPersistentHeaderDelegate
{
  String? title;
  TextWidgetHeader({this.title});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent,)
  {
    return InkWell(
      child: Container(
        decoration: const BoxDecoration(
           color: Colors.white
        ),
        height: 80.0,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: InkWell(
          child: Text(
            title!,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 30,
              color: Colors.black,
            ),
          ),
        ),

      ),
    );
  }

  @override

  double get maxExtent => 50;

  @override

  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
