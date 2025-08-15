import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'upload_image_screen.dart';
import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:major/services/storage_service.dart';
import 'package:major/utils/constants.dart';
import 'package:http/http.dart' as http;

class AiDiagnosisScreen extends StatefulWidget {
  final VoidCallback backbutton;

  const AiDiagnosisScreen({required this.backbutton, super.key});

  @override
  State<AiDiagnosisScreen> createState() => _AiDiagnosisScreenState();
}


class  _AiDiagnosisScreenState extends  State<AiDiagnosisScreen> {
  bool? isPremium;

  void _navigateToUpload(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UploadImageScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    checkUserPremium();
  }

  Future<void> checkUserPremium() async{
    String? currentUserId;

    final token = await StorageService.getToken();
    if (token == null) {
      print("No token found");
    } else {
      try {
        final payload = JwtDecoder.decode(token);
        print("Decoded payload: $payload");
        currentUserId= payload['sub'];
        print(currentUserId);
      } catch (e) {
        print("Error decoding token: $e");
      }
    }

    final url= Uri.parse('${ApiConstants.baseUrl}/users/${currentUserId}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data= jsonDecode(response.body);
        setState(() {
          isPremium = data['user']['isPremium'];
        });
      } else {
        print("Failed to fetch premium status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error making GET request: $e");
    }
  }

  Future<bool> setUserAsPremium() async{
    String? currentUserId;

    final token = await StorageService.getToken();
    if (token == null) {
      print("No token found");
    } else {
      try {
        final payload = JwtDecoder.decode(token);
        print("Decoded payload: $payload");
        currentUserId= payload['sub'];
        print(currentUserId);
      } catch (e) {
        print("Error decoding token: $e");
      }
    }

    final url= Uri.parse('${ApiConstants.baseUrl}/users/setpremium');
    try {
      final response = await http.patch(url, headers: {
        'Content-Type': 'application/json',
        'user-id': currentUserId ?? '',
      });

      if (response.statusCode == 200) {
        print("User marked as premium successfully");
        return true;
      } else {
        print("Failed to set premium. Status: ${response.statusCode}, Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error making PATCH request: $e");
      return false;
    }
  }

  void esewaPayment(BuildContext context){
    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test,
          clientId:
          'JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R',
          secretId: 'BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ==',
        ),
        esewaPayment: EsewaPayment(
          productId: "1d71jd81",
          productName: "AI Sunscription",
          productPrice: "1000",
          callbackUrl: '',
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult data) async {
          debugPrint(":::SUCCESS::: => $data");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Success: $data'),
              backgroundColor: Colors.green,
            ),
          );
          final bool premium = await setUserAsPremium();

          if (premium) {
            setState(() {
              isPremium = true;
            });
            _navigateToUpload(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Failed to update premium status"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        onPaymentFailure: (data) {
          debugPrint(":::FAILURE::: => $data");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed: $data'),
              backgroundColor: Colors.red,
            ),
          );
        },
        onPaymentCancellation: (data) {
          debugPrint(":::CANCELLATION::: => $data");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cancel: $data'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } on Exception catch (e) {
      debugPrint("EXCEPTION : ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          widget.backbutton();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Diagnosis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPremium == true ? Icons.lock_open : Icons.lock_outline,
                    size: 48,
                    color: isPremium == true ? Colors.green[600] : Colors.grey[500],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPremium == true ? 'Premium Feature Unlocked' : 'Premium Feature Locked',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isPremium == true ? Colors.green[600] : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isPremium == true
                        ? 'You can now view plant health\nthrough AI diagnosis and\nget expert insights for your crops.'
                        : 'Subscribe now to access to AI-based plant health diagnosis and\nexpert recommendations for you crops.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isPremium == true ? Colors.black : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isPremium == true) {
                          _navigateToUpload(context); // already paid
                        } else {
                          esewaPayment(context); // show payment flow
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPremium == true ? Colors.grey : Colors.green[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        isPremium == true
                            ? 'Already Paid – Tap to Proceed'
                            : 'Subscribe Now (Rs. 1,000)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}