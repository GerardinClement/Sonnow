import 'package:flutter/material.dart';
import 'package:sonnow/delayed_animation.dart';
import 'package:sonnow/pages/auth_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF424242),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(
              vertical: 100,
              horizontal: 40
          ),
          child: Column(
            children: [
              DelayedAnimation(
                  delay: 1500,
                  child: SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: Center(
                        child: Text('SONNOW', style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold
                    )),
                    )
                  )),
              DelayedAnimation(
                  delay: 2000,
                  child: SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white24,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
                              )
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => AuthPage(
                                    onLoginSuccess: () {
                                      print("Login successful");
                                    },
                                  ))
                              );
                            },
                            child: Text('Get Started', style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            )),
                        ),
                      ),
                    )
                  ),
            ],
          ),
        ),
      )
    );
  }
}