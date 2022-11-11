// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? paymentIntent;
  Future makePayment() async {
    try {
      paymentIntent = await createPaymentIntent('20', 'USD');
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent!['client_secret'],
             // applePay: PaymentSheetApplePay(merchantCountryCode: '+92'),
              //  googlePay: PaymentSheetGooglePay(testEnv:true,currencyCode:"US",)
              style: ThemeMode.dark,
              merchantDisplayName: "ALAMGIR",
          ));
      displayPaymentShee();
    } catch (e) {
      print("exception" + e.toString());
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        "amount": calculateAmount(amount),
        "currency": currency,
        "payment_method_types[]": 'card'
      };
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51M31U7CCkejsxGRe50n15C3f8DK7hgr0Jf7kK4Jiy0o7fkcYvJYHetY93cE5EtPneBQ0V6EIgeA9PizC3avwdfH300JKFDe9xZ',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return jsonDecode(response.body);
    } catch (e) {
      print("exception" + e.toString());
    }
  }

  calculateAmount(String amount) {
    final price = int.parse(amount) * 100;
    return price.toString();
  }

  displayPaymentShee() async {
    try {
      await Stripe.instance.presentPaymentSheet(
          parameters: PresentPaymentSheetParameters(
        clientSecret: paymentIntent!['client_secret'],
        confirmPayment: true,
      ));
      setState(() {
        paymentIntent = null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Paid successfully")));
    } on StripeException catch (e) {
      print(e.toString());
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text("Cancelled"),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(
          "Stripe paymentMethod",
          style: TextStyle(fontSize: 25, color: Colors.lightBlue),
        ),
      ),
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await makePayment();
              },
              child: Text("Make Payment"),
            ),
          )
        ],
      )),
    );
  }
}
