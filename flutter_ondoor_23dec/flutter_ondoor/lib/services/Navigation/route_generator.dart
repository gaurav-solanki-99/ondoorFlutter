import 'package:flutter/material.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/models/AllProducts.dart';
import 'package:ondoor/models/ShippingCharges.dart';
import 'package:ondoor/models/get_shopping_list_response.dart';
import 'package:ondoor/models/shop_by_category_response.dart';
import 'package:ondoor/screens/AuthScreen/Register/RegisterScreen.dart';
import 'package:ondoor/screens/AuthScreen/Verify/VerifyScreen.dart';
import 'package:ondoor/screens/CheckoutScreen/OrderSummaryScreen.dart';
import 'package:ondoor/screens/CheckoutScreen/checkoutScreen.dart';
import 'package:ondoor/screens/FeaturedProduct/FeaturedProductScreen.dart';
import 'package:ondoor/screens/PaymentOptions/PaymenOptionScreen.dart';
import 'package:ondoor/screens/ProductValidationscreen/productvalidationscreen.dart';
import 'package:ondoor/screens/SplashScreen/SplashScreen.dart';
import 'package:ondoor/screens/company_info_page/company_info_page.dart';
import 'package:ondoor/screens/contact_us_screen/contact_us_screen.dart';
import 'package:ondoor/screens/edit_profile/edit_profile_screen.dart';
import 'package:ondoor/screens/location_screen/location_screen.dart';
import 'package:ondoor/screens/notification_screen/notification_list_screen.dart';
import 'package:ondoor/screens/order_history_detail/order_history_detail_screen.dart';
import 'package:ondoor/screens/order_history_screen/order_history_screen.dart';
import 'package:ondoor/screens/order_on_phone/order_on_phone_screen.dart';
import 'package:ondoor/screens/order_status_screen/order_status_screen.dart';
import 'package:ondoor/screens/product_detail/product_detail_screen.dart';
import 'package:ondoor/screens/profile_screen/profile_screen.dart';
import 'package:ondoor/screens/shop_by_category/shop_by_category_screen.dart';
import 'package:ondoor/screens/shopping_list_detail_screen/shopping_list_detail_screen.dart';
import 'package:ondoor/screens/shopping_list_screen/shopping_list_screen.dart';
import 'package:ondoor/services/Navigation/routes.dart';

import '../../models/shop_by_category_response.dart';
import '../../screens/HomeScreen/HomePageScreen.dart';
import '../../screens/change_address_screen/ChangeAddressScreen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;
    debugPrint("ROUTE TO ${settings.name}");
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) =>  SplashScreen());
      case Routes.home_page:
        return MaterialPageRoute(builder: (_) => const Homepagescreen());

      case Routes.shop_by_category:
        Map<String, dynamic> arguementData =
            settings.arguments as Map<String, dynamic>;

        return _customPageRoute(
            ShopByCategoryScreen(
              arguementData: {
                "selected_category": arguementData["selected_category"],
                "category_list": arguementData["category_list"],
                "selected_sub_category": arguementData["selected_sub_category"],
              },
            ),
            SlideDirection.rightToLeft);

        return MaterialPageRoute(
            builder: (_) => ShopByCategoryScreen(
                  arguementData: {
                    "selected_category": arguementData["selected_category"],
                    "category_list": arguementData["category_list"],
                    "selected_sub_category":
                        arguementData["selected_sub_category"],
                  },
                ));
      case Routes.location_screen:
        return MaterialPageRoute(
            builder: (_) => LocationScreen(
                  args: settings.arguments!,
                ));
      case Routes.order_status_screen:
        Map<String, dynamic> arguementData =
            settings.arguments as Map<String, dynamic>;
        bool success = arguementData['success'];
        int order_id = arguementData['order_id'];
        String message = arguementData['message'];
        String paid_by = arguementData['paid_by'];
        String coupon_id = arguementData['coupon_id'];
        String rating_redirect_url = arguementData['rating_redirect_url'];
        String delivery_location = arguementData['delivery_location'];
        String selected_time_slot = arguementData['selected_time_slot'];
        String selected_date_slot = arguementData['selected_date_slot'];
        dynamic amount = arguementData['amount'];
        return MaterialPageRoute(
            builder: (_) => OrderStatusScreen(
                  order_id: order_id,
                  amount: amount,
                  coupon_id: coupon_id,
                  rating_redirect_url: rating_redirect_url,
                  message: message,
                  paid_by: paid_by,
                  success: success,
                  delivery_location: delivery_location,
                  selected_time_slot: selected_time_slot,
                  selected_date_slot: selected_date_slot,
                ));

      case Routes.ordersummary_screen:
        final Map arguments = settings.arguments as Map;
        final ProductsIds = arguments['ProductsIds'];
        final response = arguments['response'];

        // return MaterialPageRoute(
        //     builder: (_) => OrderSummaryscreen(
        //           ProductsIds: ProductsIds,
        //           response: response,
        //         ));

        return _customPageRoute(
            OrderSummaryscreen(
              ProductsIds: ProductsIds,
              response: response,
            ),
            SlideDirection.leftToRight);

      case Routes.checkoutscreen:
        final Map arguments = settings.arguments as Map;
        final listUnit = arguments['list'];
        final list_cOffers = arguments['list_cOffers'];

        return _customPageRoute(
            Checkoutscreen(
              freeProducts: listUnit,
              c_offerlist: list_cOffers,
            ),
            SlideDirection.bottomToTop);

      // return MaterialPageRoute(
      //     builder: (_) => Checkoutscreen(
      //           freeProducts: listUnit,
      //           c_offerlist: list_cOffers,
      //         ));
      // case Routes.reward_summary:
      //   return MaterialPageRoute(builder: (_) => const RewardSummaryScreen());
      case Routes.productValidation:
        final Map arguments = settings.arguments as Map;
        final listUnit = arguments['list'];
        final list_cOffers = arguments['list_cOffers'];
        final title = arguments['title'];
        final subtitle = arguments['subtitle'];
        final details = arguments['details'];
        bool mixed = arguments['mixed']??false;
        final recurring = arguments['recurring'];
        final totalitemAllowed = arguments['totalitemAllowed'];

        return MaterialPageRoute(
            builder: (_) => Productvalidationscreen(
                  listproduct: listUnit,
                  list_cOffers: list_cOffers,
                  title: title,
                  subtitle: subtitle,
                  details: details,
                  mixed: mixed,
                  recurring: recurring,
                  totalitemAllowed: totalitemAllowed,
                ));
      case Routes.product_Detail_screen:
        final Map arguments = settings.arguments as Map;

        debugPrint("ProductDetails Argument ${arguments}");

        // Accessing individual arguments
        final listUnit = arguments['list'];
        final index = arguments['index'];
        final fromchekcout = arguments['fromchekcout'];
        /* return MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
                  listproduct: listUnit,
                  selectedIndex: index,
                ));*/

        return _customPageRoute(
            ProductDetailScreen(
              listproduct: listUnit,
              selectedIndex: index, fromchekcout: fromchekcout,
            ),
            SlideDirection.bottomToTop);

      case Routes.featuredProduct:
        final args = settings.arguments as Map<String, dynamic>;

        debugPrint("Arguments " + args.toString());

        // return MaterialPageRoute(
        //     builder: (_) => FeaturedProductScreen(
        //           title: args["key"]!,
        //           listdata: args["list"]! as List<ProductData>,
        //         ));

        return _customPageRoute(
            FeaturedProductScreen(
              title: args["key"]!,
              listdata: args["list"]! as List<ProductData>,
              paninatinUrl: args["paninatinUrl"]!,
            ),
            SlideDirection.rightToLeft);

      case Routes.change_address:
        final String arguments = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => Changeaddressscreen(
            args: arguments,
          ),
        );
      case Routes.profile_screen:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case Routes.order_by_phone:
        return MaterialPageRoute(builder: (_) => const OrderOnPhoneScreen());
      case Routes.contact_us:
        final Map arguments = settings.arguments as Map;
        //"userName":userName,"email":"","telephone":""
        return MaterialPageRoute(
            builder: (_) => ContactUsScreen(
                  userName: arguments['userName'],
                  email: arguments['email'],
                  telephone: arguments['telephone'],
                ));
      case Routes.register_screen:
        String fromRoute = settings.arguments as String;


        return MaterialPageRoute(
            builder: (_) => RegisterScreen(
                  fromRoute: fromRoute,
                ));
      case Routes.payment_option:
        Map paymentData = settings.arguments as Map;
        // "cart_item_list":
        // cartitesmList,
        // "shipping_charge": shippingCharge,
        // "saving_amount": savingamount,
        // "is_show_shipping":isShowShipping,
        List<ProductUnit> productUnit = paymentData["cart_item_list"];
        List<PaymentGetway> payment_gateways = paymentData["payment_gateways"];
        double shipping_charge = paymentData['shipping_charge'];
        double saving_amount = paymentData['saving_amount'];
        double sub_total = paymentData['sub_total'];
        double grand_total = paymentData['grand_total'];
        return MaterialPageRoute(
            builder: (_) => PaymentOptionScreen(
                  cartitesmList: productUnit,
                  // saving_amount: saving_amount,
                  // shipping_charge: shipping_charge,
                  // grand_total: grand_total,
                  // sub_total: sub_total,
                  // payment_gateways: payment_gateways,
                ));
      case Routes.company_info_page:
        final String arguments = settings.arguments as String;
        String page_name = "";
        if (arguments == "3") {
          page_name = StringContants.lbl_privacy_policy;
        } else if (arguments == "4") {
          page_name = StringContants.lbl_about_us;
        } else if (arguments == "5") {
          page_name = StringContants.lbl_terms_and_conditions;
        } else if (arguments == "15") {
          page_name = StringContants.lbl_ondoor_rewards;
        }
        return MaterialPageRoute(
            builder: (_) => CompanyInfoPage(
                  page_id: arguments,
                  page_name: page_name,
                ));
      case Routes.verify_screen:
        final Map arguments = settings.arguments as Map;
        final name = arguments['name'];
        final mobile = arguments['mobile'];
        final email = arguments['email'];
        final fromRoute = arguments['fromRoute'];
        return MaterialPageRoute(
            builder: (_) => VerifyScreen(
                  name: name,
                  mobileNo: mobile,
                  email: email,
                  fromRoute: fromRoute,
                ));
      case Routes.edit_profile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case Routes.order_history:
        return MaterialPageRoute(builder: (_) => const OrderHistoryScreen());
      case Routes.order_history_detail:
        final Map arguments = settings.arguments as Map;
        final order_id = arguments['order_id'];
        final order_type = arguments['order_type'];
        return MaterialPageRoute(
            builder: (_) => OrderHistoryDetailScreen(
                  order_id: order_id, order_type:order_type,
                ));
      case Routes.shopping_list:
        return MaterialPageRoute(builder: (_) => const ShoppingListScreen());
      case Routes.shopping_list_detail:
        final Shoppinglist shoppinglistDetail =
            settings.arguments as Shoppinglist;
        return MaterialPageRoute(
            builder: (_) => ShoppingListDetailScreen(
                shoppinglistDetail: shoppinglistDetail));

      case Routes.notification_center:
        // return MaterialPageRoute(
        //     builder: (_) => const NotificationListScreen());

        return _customPageRoute(
            NotificationListScreen(), SlideDirection.leftToRight);

      // If args is not of the correct type, return an error page.
      // You can also throw an exception while in development.
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _customPageRoute(
      Widget page, SlideDirection direction) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        late Offset begin;
        late Offset end;

        // Determine the begin and end positions based on the direction
        switch (direction) {
          case SlideDirection.leftToRight:
            begin = const Offset(-1.0, 0.0); // Start off screen to the left
            end = Offset.zero; // End at the center of the screen
            break;
          case SlideDirection.rightToLeft:
            begin = const Offset(1.0, 0.0); // Start off screen to the right
            end = Offset.zero;
            break;
          case SlideDirection.topToBottom:
            begin = const Offset(0.0, -1.0); // Start off screen at the top
            end = Offset.zero;
            break;
          case SlideDirection.bottomToTop:
            begin = const Offset(0.0, 1.0); // Start off screen at the bottom
            end = Offset.zero;
            break;
        }

        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }

  static Route<dynamic> removeRoute() {
    return MaterialPageRoute(builder: (context) => const ShoppingListScreen());
  }
}

enum SlideDirection { leftToRight, rightToLeft, topToBottom, bottomToTop }
