import 'package:flutter/material.dart';

class PageOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(210, 161, 161, 1),
        body: Container(
          height: MediaQuery.of(context).size.height * 0.96,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                child: Text(
                  "SagtaGram",
                  style: TextStyle(fontSize: 30),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.55,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('asset/images/pageoneimage.png')),
                  )),
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                focusElevation: 0,
                elevation: 10,
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: Color.fromRGBO(235, 217, 217, 1),
                splashColor: Colors.red,
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.10,
                  width: MediaQuery.of(context).size.width * 0.80,
                  child: Text("Log in"),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                focusElevation: 0,
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                splashColor: Colors.red,
                color: Color.fromRGBO(235, 217, 217, 1),
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/signup');
                },
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.10,
                  width: MediaQuery.of(context).size.width * 0.80,
                  child: Text("Sign up"),
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
