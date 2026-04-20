import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/stripe_config.dart';

class StripeService {
  static const Map<String, String> _testTokens = {
    '1212121212121212': 'tok_visa',
    '2222222222222222': 'tok_visa_debit',
    '2323232323232323': 'tok_mastercard',
    '1515151515151515': 'tok_mastercard_debit',
    '1313131313131313': 'tok_chargedDeclined',
    '4141414141414141': 'tok_chargedDeclinedInsufficientFunds',
  };

  static Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvc,
  }) async {
    if (StripeConfig.secretKey.trim().isEmpty) {
      return <String, dynamic>{
        'success': false,
        'error': 'Stripe secret key is not configured. Set StripeConfig.secretKey in lib/config/stripe_config.dart.',
      };
    }

    final amountInCentavos = (amount * 100).round().toString();
    final cleanCard = cardNumber.replaceAll(' ', '');
    final token = _testTokens[cleanCard];

    if (token == null) {
      return <String, dynamic>{
        'success': false,
        'error': 'unknown test card',
      };
    }

    try {
      final response = await http.post(
        Uri.parse('${StripeConfig.apiUrl}/payment_intents'),
        headers: <String, String>{
          'Authorization': 'Bearer ${StripeConfig.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: <String, String>{
          'amount': amountInCentavos,
          'currency': 'php',
          'payment_method_types[]': 'card',
          'payment_method_data[type]': 'card',
          'payment_method_data[card][token]': token,
          'confirm': 'true',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == 'succeeded') {
        return <String, dynamic>{
          'success': true,
          'id': data['id'].toString(),
          'amount': (data['amount'] as num) / 100,
          'status': data['status'].toString(),
        };
      } else {
        final errorMsg = data['error'] is Map
            ? (data['error'] as Map)['message']?.toString() ?? 'payment failed'
            : 'payment failed';
        return <String, dynamic>{
          'success': false,
          'error': errorMsg,
        };
      }
    } catch (e) {
      return <String, dynamic>{
        'success': false,
        'error': e.toString(),
      };
    }
  }
}