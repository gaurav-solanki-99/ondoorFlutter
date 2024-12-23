import 'package:flutter/material.dart';
import 'package:ondoor/constants/FontConstants.dart';
import 'package:ondoor/screens/NewAnimation/animation_bloc.dart';
import 'package:ondoor/screens/NewAnimation/animation_event.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/widgets/AppWidgets.dart';

import '../constants/Constant.dart';
import '../screens/HomeScreen/HomeBloc/home_page_bloc.dart';
import '../screens/HomeScreen/HomeBloc/home_page_event.dart';
import '../utils/Comman_Loader.dart';
import '../utils/Commantextwidget.dart';

class AnimatedDropdownButton<T> extends StatefulWidget {
  HomePageBloc homePageBloc;
  AnimationBloc animationBloc;
  bool isOpenBottomview;
  final List<T> items;
  final T selectedItem;
  final AnimationController controller;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemBuilder;
  final String Function(T) selectedItemBuilder;
  final BorderRadius? borderRadius;

  AnimatedDropdownButton({
    required this.animationBloc,
    required this.homePageBloc,
    required this.isOpenBottomview,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.controller,
    required this.itemBuilder,
    required this.selectedItemBuilder,
    this.borderRadius,
  });

  @override
  _AnimatedDropdownButtonState<T> createState() =>
      _AnimatedDropdownButtonState<T>();
}

class _AnimatedDropdownButtonState<T> extends State<AnimatedDropdownButton<T>>
    with SingleTickerProviderStateMixin {
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;
  OverlayEntry? _overlayEntry;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _expandAnimation = CurvedAnimation(
      parent: widget.controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    print("IS OPEN BOTTOM ${widget.isOpenBottomview}");
    return GestureDetector(
      onTap: () {
        if (widget.isOpenBottomview == false) {
          _toggleDropdown();
        } else {
          widget.animationBloc.add(AnimationCartEvent(size: 70.00));
          _toggleDropdown();
        }
      },
      child: Center(
        child: Container(
          key: _key,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  widget.selectedItemBuilder(widget.selectedItem),
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: Fontconstants.fc_family_proxima,
                    fontWeight: FontWeight.w700,
                    color: ColorName.ColorBagroundPrimary,
                  ),
                  overflow: TextOverflow
                      .ellipsis, // Prevent overflow and add ellipsis
                  maxLines: 1, // Limit to one line
                ),
              ),
              // SizedBox(width: 5), // Add spacing between text and icon
              Icon(
                widget.controller.status == AnimationStatus.forward
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleDropdown() {
    if (_isExpanded) {
      widget.controller.reverse().then((_) {
        widget.homePageBloc.add(HomeBottomSheetEvent(status: false));
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    } else {
      widget.controller.forward();
      _showDropdownMenu();
    }
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _showDropdownMenu() {
    widget.homePageBloc.add(HomeBottomSheetEvent(status: true));
    final overlay = Overlay.of(context);
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final buttonHeight = renderBox.size.height;
    final buttonWidth = Sizeconfig.getWidth(context);
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            print("widget.controller.status2   ${widget.isOpenBottomview}");
            if (widget.isOpenBottomview == false) {
              _toggleDropdown();
            }
          },
          child: Stack(
            children: [
              Positioned(
                top: position.dy + buttonHeight + buttonHeight / 3,
                left: buttonWidth / 3.5,
                width: buttonWidth * .5,
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(5),
                  color: ColorName.whiteSmokeColor,
                  child: SizeTransition(
                    sizeFactor: _expandAnimation,
                    axisAlignment: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: widget.items.map((item) {
                        return MediaQuery(
                          data: Appwidgets()
                              .mediaqueryDataforWholeApp(context: context),
                          child: GestureDetector(
                            onTap: () {
                              widget.onChanged(item);
                              print(
                                  "widget.controller.status1   ${widget.isOpenBottomview}");
                              _toggleDropdown();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: ColorName.ColorBagroundPrimary,
                                  borderRadius: BorderRadius.circular(10)),
                              width: buttonWidth * .5,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              child: Text(
                                widget.itemBuilder(item),
                                style: Appwidgets()
                                    .commonTextStyle(ColorName.black)
                                    .copyWith(
                                        fontSize: 18,
                                        fontFamily: Fontconstants.fc_family_sf,
                                        fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    overlay.insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _isExpanded = false;
    if (widget.controller != null) {
      widget.controller.dispose();
    }
    _overlayEntry?.remove();
    CommanLoader().dismissEasyLoader();
    super.dispose();
  }
}
