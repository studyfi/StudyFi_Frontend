import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyfi/screens/login_page.dart';
import 'package:studyfi/services/api_service.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool isInvalid = false;
  int attemptCount = 0;
  final int maxAttempts = 5;
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final enteredCode = _controllers.map((c) => c.text).join();

    if (enteredCode.length != 6) return;

    bool isValid =
        await _apiService.validateEmailCode(widget.email, enteredCode);

    if (isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email verified successfully!"),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } else {
      setState(() {
        isInvalid = true;
        attemptCount += 1;
      });
      if (attemptCount >= maxAttempts) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Too many invalid attempts. Please try again later."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Invalid code. ${maxAttempts - attemptCount} attempts left.")),
        );
      }
    }
  }

  Future<void> _resendCode() async {
    bool sent = await _apiService.resendEmailCode(widget.email);

    if (sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Verification code resent to your email."),
        ),
      );
      setState(() {
        attemptCount = 0;
        isInvalid = false;
        for (var c in _controllers) {
          c.clear();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to resend code. Please try again."),
        ),
      );
    }
  }

  Widget _buildCodeBox(int index) {
    return SizedBox(
      width: 45,
      child: Focus(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.text, // Allows alphanumeric keyboard
          maxLength: 1,
          style: const TextStyle(fontSize: 20),
          decoration: const InputDecoration(
            counterText: '',
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) async {
            setState(() => isInvalid = false);

            // PASTE CASE — 6 characters (alphanumeric)
            if (index == 0 && value.length == 6) {
              for (int i = 0; i < 6; i++) {
                _controllers[i].text = value[i];
              }
              _focusNodes[5].requestFocus();
              Future.delayed(const Duration(milliseconds: 100), _handleSubmit);
              return;
            }

            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            }

            if (index == 5 && value.isNotEmpty) {
              _handleSubmit();
            }
          },
        ),
        onKey: (node, event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            if (_controllers[index].text.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
              _controllers[index - 1].clear();
            }
          }
          return KeyEventResult.ignored;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showError = isInvalid || attemptCount >= maxAttempts;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter the 6-character verification code sent to ${widget.email}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (i) => _buildCodeBox(i)),
            ),
            if (showError)
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 8),
                child: Text(
                  attemptCount >= maxAttempts
                      ? "Too many invalid attempts."
                      : "Incorrect code. Try again.",
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 13,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: attemptCount >= maxAttempts ? null : _resendCode,
                child: const Text("Resend Code"),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: attemptCount >= maxAttempts ? null : _handleSubmit,
                child: const Text("Verify"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
