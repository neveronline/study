import 'package:flutter/material.dart';
import 'package:flutter_study/component/cache/HttpRequestCaches.dart';
import 'package:flutter_study/component/dialog/Dialogs.dart';
import 'package:flutter_study/component/sp/SharedPreferenceHelper.dart';
import 'package:flutter_study/constant/SpConstant.dart';
import 'package:flutter_study/locale/Translations.dart';

class DevelopSetting extends StatefulWidget {
  @override
  _DevelopSetting createState() => new _DevelopSetting();
}

class _DevelopSetting extends State<DevelopSetting> {
  String _protocol = "";
  String _host = "";
  String _port = "";

  @override
  Widget build(BuildContext context) {
    initValues();
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.textOf(context, "settings.devTool.title")),
      ),
      body: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 16),
        child: Column(children: <Widget>[
          Container(
            child: new GestureDetector(
              onTap: () {
                List<String> list = [];
                list.add("http");
                list.add("https");
                Dialogs.showListBottomSheet(context, list).then((value) =>
                    {refreshState(SpConstant.protocol_key, list[value])});
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(Translations.textOf(
                      context, "settings.devTool.protocol")),
                  Text('${_protocol}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: new GestureDetector(
              onTap: () {
                Dialogs.showInputDialog(
                        context,
                        Translations.textOf(context, "settings.devTool.host"),
                        '${_host}')
                    .then(
                        (value) => {refreshState(SpConstant.host_key, value)});
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(Translations.textOf(context, "settings.devTool.host")),
                  Text('${_host}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: new GestureDetector(
              onTap: () {
                Dialogs.showInputDialog(
                        context,
                        Translations.textOf(context, "settings.devTool.port"),
                        '${_port}')
                    .then(
                        (value) => {refreshState(SpConstant.port_key, value)});
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(Translations.textOf(context, "settings.devTool.port")),
                  Text('${_port}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                    ),
                    onPressed: () => {},
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void refreshState(String key, String value) async {
    bool res = await SharedPreferenceHelper.set(key, value);
    if (res) {
      setState(() {
        if (key == SpConstant.protocol_key) {
          _protocol = value;
        } else if (key == SpConstant.host_key) {
          _host = value;
        } else if (key == SpConstant.port_key) {
          _port = value;
        }
      });
      HttpRequestCaches.init();
    }
  }

  void initValues() {
    setState(() {
      _protocol = HttpRequestCaches.getProtocol();
      _host = HttpRequestCaches.getHost();
      _port = HttpRequestCaches.getPort();
    });
  }
}
