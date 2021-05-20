import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_study/component/cache/Caches.dart';
import 'package:flutter_study/component/http/HttpRequests.dart';
import 'package:flutter_study/component/log/Logs.dart';
import 'package:flutter_study/constant/HttpConstant.dart';
import 'package:flutter_study/constant/RouteNameConstant.dart';
import 'package:flutter_study/locale/Translations.dart';
import 'package:flutter_study/model/QueryTvResult.dart';

class TV extends StatefulWidget {
  @override
  _TV createState() => _TV();
}

class _TV extends State<TV> {
  List<TvItem> list;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    list = [];
    _onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.textOf(context, "tv.list.title")),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // 底部导航
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: Translations.textOf(context, "tv.list.bottomAll")),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: Translations.textOf(context, "tv.list.bottomFavorite")),
        ],
        currentIndex: _currentIndex,
        fixedColor: Colors.blue,
        onTap: _onItemTapped,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: list.length == 0
            ? Center(
                child: Text(
                  Translations.textOf(context, "all.list.view.no.data"),
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.separated(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return new GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                            RouteNameConstant.route_name_tv_player,
                            arguments: list[index]);
                      },
                      child: ListTile(
                          title: Text(list[index].name),
                          trailing: new GestureDetector(
                              onTap: () {
                                _setFavorite(list[index]);
                              },
                              child: list[index].isFavorite
                                  ? Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                    )
                                  : Icon(Icons.favorite_border))));
                },
                separatorBuilder: (context, index) => Divider(height: .0),
              ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _onRefresh();
    });
  }

  Future<Null> _onRefresh() async {
    Map<String, dynamic> paramJson = new HashMap();
    paramJson.putIfAbsent("favoriteUserId", () => Caches.getUserId());
    paramJson.putIfAbsent("isOnlyFavorite", () => _currentIndex == 1);
    paramJson.putIfAbsent("targetPage", () => 1);
    paramJson.putIfAbsent("pageSize", () => 100);
    Map<String, String> param = new HashMap();
    param.putIfAbsent("param", () => json.encode(paramJson));
    print(json.encode(paramJson));
    HttpRequests.get(HttpConstant.url_tv_query_page, param, null)
        .then((result) {
      Logs.info('_onRefresh responseBody=' + result?.responseBody);
      setState(() {
        QueryTvResult tvResult =
            QueryTvResult.fromJson(json.decode(result?.responseBody));
        if (tvResult.code == 200) {
          list = tvResult.data;
        }
      });
    }).catchError((error) {
      print(error.toString());
    });
  }

  Future<Null> _setFavorite(TvItem item) async {
    item.isFavorite = !item.isFavorite;
    item.userId = Caches.getUserId();
    Map<String, String> param = new HashMap();
    param.putIfAbsent("param", () => json.encode(item.toJson()));
    print(json.encode(item.toJson()));
    HttpRequests.post(HttpConstant.url_tv_set_favorite, param, null)
        .then((result) {
      Logs.info('_setFavorite responseBody=' + result?.responseBody);
      _onRefresh();
    });
  }
}
