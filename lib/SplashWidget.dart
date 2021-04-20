import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashWidget extends StatefulWidget {
  final Map<String, double> data;
  final dateController = TextEditingController();
  final amountController = TextEditingController();
  SplashWidget({Key key, this.data}) : super(key: key);

  @override
  State createState() => _SplashState();
}

class _SplashState extends State<SplashWidget> {
  final pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now().toLocal();

    _saveSP("todayDate",
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch);
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  bool isDate(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null && int.parse(s) < 32 && int.parse(s) > 0;
  }

  finishSplash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('seen', true);
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  nextPage() {
    setState(() {
      _currentIndex += 1;
      pageController.animateToPage(_currentIndex,
          duration: Duration(milliseconds: 1000), curve: Curves.ease);
    });
  }

  showSnackBar(BuildContext context, String s) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(s),
      duration: Duration(seconds: 3),
    ));
  }

  Widget introScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(15),
          child: Center(
              child: Image(
            image: AssetImage('assets/my_icon.png'),
            width: 150,
          )),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
          child: Center(
            child: Text(
              "Welcome to CashTrack.",
              style: TextStyle(fontSize: 35),
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: Center(
                child: Text(
//                  "1. Choose your monthly reset date\n"
              "1. Set your Daily Limit 👏\n"
              "2. Keep recording your spendings 🙌\n"
              "3. See how much you've saved! 😎\n"
              "4. You can also add & track subscriptions✌ ",
              style: TextStyle(fontSize: 18, height: 1.6),
            ))),
        Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            margin: EdgeInsets.fromLTRB(50, 10, 50, 10),
            color: Color.fromRGBO(149, 213, 178, 1),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                      onTap: () {
                        nextPage();
                      },
                      title: Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 22,
                        ),
                        textAlign: TextAlign.center,
                      ))
                ]))
      ],
    );
  }

  Widget dailyLimit(BuildContext context) {
    return Builder(
        builder: (context) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Center(
                    child: Icon(
                      Icons.attach_money_rounded,
                      size: 200,
                      color: Color.fromRGBO(149, 213, 178, 1),
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                    child: Center(
                        child: Text(
                      "How much would you like to \nspend daily on average?",
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ))),
                Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
                    child: Center(
                      child: ListTile(
                          title: new Row(
                        children: <Widget>[
                          Flexible(
                              child: TextField(
                            controller: widget.amountController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter Your Daily Limit',
                            ),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                          ))
                        ],
                      )),
                    )),
                Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    margin: EdgeInsets.fromLTRB(60, 30, 60, 30),
                    color: Color.fromRGBO(149, 213, 178, 1),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                              onTap: () {
                                if (widget.amountController.text.isNotEmpty) {
                                  if (isNumeric(widget.amountController.text)) {
                                    _saveSP(
                                        "dailyLimit",
                                        num.parse(
                                            widget.amountController.text));
                                    finishSplash();
                                  } else {
                                    showSnackBar(context,
                                        "Your input is invalid. Please Check and try again");
                                  }
                                } else {
                                  showSnackBar(context,
                                      "Please enter the initial amount. Duh!");
                                }
                              },
                              title: Text(
                                "Start",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ))
                        ]))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> introPages = <Widget>[
      introScreen(context),
      dailyLimit(context),
    ];
    return Scaffold(
      body: Builder(
          builder: (context) => PageView(
              physics: new NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                FocusScope.of(context).unfocus();
                _currentIndex = index;
              },
              controller: pageController,
              children: introPages)),
    );
  }

  _saveSP(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is String) {
      prefs.setString(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is int) {
      prefs.setInt(key, value);
    } else if (value is double) {
      prefs.setDouble(key, value);
    } else {
      prefs.setStringList(key, value);
    }
  }
}
