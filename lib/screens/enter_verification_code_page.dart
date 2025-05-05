import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyfi/screens/new_password_page.dart';

class EnterVerificationCodePage extends StatefulWidget {
  final String email;
  final String actualCode;

  const EnterVerificationCodePage({
    super.key,
    required this.email,
    required this.actualCode,
  });

  @override
  State<EnterVerificationCodePage> createState() =>
      _EnterVerificationCodePageState();
}

class _EnterVerificationCodePageState extends State<EnterVerificationCodePage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool isInvalid = false;
  int attemptCount = 0;
  final int maxAttempts = 5;

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

  void _handleSubmit() {
    final enteredCode = _controllers.map((c) => c.text).join();

    if (enteredCode.length != 6) return;

    if (enteredCode == widget.actualCode) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NewPasswordPage(
            email: widget.email,
            verificationCode: enteredCode,
          ),
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

  Widget _buildCodeBox(int index) {
    return SizedBox(
      width: 45,
      child: Focus(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(fontSize: 20),
          decoration: InputDecoration(
            counterText: '',
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isInvalid ? Colors.red.shade700 : Colors.grey,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isInvalid ? Colors.red.shade700 : Colors.blue,
                width: 2,
              ),
            ),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) async {
            setState(() => isInvalid = false);

            // PASTE CASE — 6 digits
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
            const Text(
              "Enter the 6-digit verification code sent to your email",
              style: TextStyle(fontSize: 16),
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
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: attemptCount >= maxAttempts ? null : _handleSubmit,
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
