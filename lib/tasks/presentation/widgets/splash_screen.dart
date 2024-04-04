import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:timesheet_management/tasks/presentation/views/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.forward();

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade700,
      body: SizedBox(
        width: double.infinity,
        // decoration: const BoxDecoration(
        // gradient: LinearGradient(
        //   colors: [
        //     Color.fromARGB(255, 255, 255, 255),
        //     // Colors.amber.shade600,
        //     Color.fromARGB(255, 233, 33, 19),
        //   ],
        //   begin: Alignment.centerLeft,
        //   end: Alignment.centerRight,
        // ),
        // ),
        child: FadeTransition(
          opacity: _fadeInAnimation,
          // child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/splash2.json',
                width: 300,
                height: 200,
              ),
              // Image.asset(
              //   'assets/images/logo1.png',
              //   width: 150,
              //   height: 200,
              // ),
              // const SizedBox(height: 10),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "TimeLance",
                style: TextStyle(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 35,
                ),
              ),
              const Text(
                '--Make Your Time Wise--',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                  fontSize: 20,
                ),
              )
            ],
          ),
          // ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:lottie/lottie.dart';
// // import 'package:timesheet_management/main.dart';
// import 'package:timesheet_management/tasks/presentation/views/home.dart';
// // import 'package:timesheet_management/tasks/presentation/views/home.dart';
// import 'package:timesheet_management/tasks/presentation/views/login_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key, this.email}) : super(key: key);
//   final String? email;

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeInAnimation;

//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 3000),
//     );

//     _fadeInAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_animationController);

//     _animationController.forward();

//     _checkLoginStatus();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: SystemUiOverlay.values);
//     super.dispose();
//   }

//   Future<void> _checkLoginStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

//     // Wait for the animation to complete before navigating
//     await Future.delayed(const Duration(seconds: 3));

//     if (isLoggedIn) {
//       // After successful login
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.setBool('isLoggedIn', true);
//       // Navigate to main page if logged in
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//             builder: (_) => Home(
//                   email: widget.email??'',
//                 )),
//         // Replace MainPage with your main pag
//       );
//     } else {
//       // Navigate to login page if not logged in
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               // Color.fromARGB(255, 255, 255, 255),
//               Colors.amber.shade600,
//               const Color.fromARGB(255, 233, 33, 19),
//             ],
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//           ),
//         ),
//         child: FadeTransition(
//           opacity: _fadeInAnimation,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Lottie.asset(
//                 'assets/lottie/splash2.json',
//                 width: 300,
//                 height: 200,
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 "Kumaran TimeSheets",
//                 style: TextStyle(
//                   fontStyle: FontStyle.italic,
//                   color: Colors.white,
//                   fontSize: 32,
//                 ),
//               ),
//               const Text(
//                 '--Manage Your Time--',
//                 style: TextStyle(
//                   fontStyle: FontStyle.italic,
//                   color: Colors.black,
//                   fontSize: 20,
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
