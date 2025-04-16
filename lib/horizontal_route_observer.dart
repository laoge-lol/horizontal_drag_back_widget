import 'package:flutter/material.dart';

///
///@auther Gever
///created at 2025/1/24/16:48


class HorizontalRouteObserver<R extends Route<dynamic>> extends RouteObserver<R> {
  
  List<String> history = [];

  int get length => history.length;

  static HorizontalRouteObserver getInstance() => _instance;

  static final HorizontalRouteObserver _instance = HorizontalRouteObserver._();

  HorizontalRouteObserver._();

  static const gHdbw = "g_hdbw_";

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    var name = route.settings.name ?? '';
    if (name.isNotEmpty) {
      history.add(name);
    }
    else{
      history.add("$gHdbw${history.length+1}");
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    var name = route.settings.name?? '';
    if(name.isNotEmpty) {
      history.remove(name);
    }
    else{
      history.remove("$gHdbw${history.length}");
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      var index = history.indexWhere((element) {
        return element == oldRoute?.settings.name;
      });
      var name = newRoute.settings.name ?? '';
      if (name.isNotEmpty) {
        if (index > 0) {
          history[index] = name;
        } else {
          history.add(name);
        }
      }else{
        if (index > 0) {
          history[index] = "$gHdbw$index}";
        } else {
          history.add("$gHdbw${history.length+1}");
        }
      }
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    var name = route.settings.name?? '';
    if(name.isNotEmpty) {
      history.remove(name);
    }
    else{
      history.remove("$gHdbw${history.length}");
    }
  }
}
