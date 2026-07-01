import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yaso_distributor/config/collections.dart';
import 'package:yaso_distributor/responsive_scaffold/responsive_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final mobileController = TextEditingController();
  final pinController = TextEditingController();

  final nameController = TextEditingController();
  final companyController = TextEditingController();
  final addressController = TextEditingController();
  final areasController = TextEditingController();
  final confirmPinController = TextEditingController();

  bool loading = false;
  bool mobileChecked = false;
  bool isExistingUser = false;

  bool obscurePin = true;
  bool obscureConfirmPin = true;
  bool obscureLoginPin = true;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  Future<void> checkMobile() async {
    try {
      if (mobileController.text.trim().isEmpty) {
        throw Exception("Enter mobile number");
      }

      setState(() => loading = true);

      final query = await FirebaseFirestore.instance
          .collection(Collections.distributors)
          .where('mobile', isEqualTo: mobileController.text.trim())
          .limit(1)
          .get();

      setState(() {
        mobileChecked = true;
        isExistingUser = query.docs.isNotEmpty;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll("Exception: ", ""),
          ),
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> registerDistributor() async {
    try {
      if (nameController.text.trim().isEmpty) {
        throw Exception("Enter name");
      }

      if (companyController.text.trim().isEmpty) {
        throw Exception("Enter company name");
      }

      if (addressController.text.trim().isEmpty) {
        throw Exception("Enter address");
      }

      if (areasController.text.trim().isEmpty) {
        throw Exception("Enter areas");
      }

      if (pinController.text.trim().isEmpty) {
        throw Exception("Enter PIN");
      }

      if (pinController.text.trim() !=
          confirmPinController.text.trim()) {
        throw Exception("PIN does not match");
      }

      setState(() => loading = true);

      await FirebaseFirestore.instance
          .collection(Collections.distributors)
          .add({
        "name": nameController.text.trim(),
        "mobile": mobileController.text.trim(),
        "companyName": companyController.text.trim(),
        "address": addressController.text.trim(),
      "pincodes": areasController.text
    .split(',')
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .toList(),
        "pin": pinController.text.trim(),
        "isActive": false,
        "createdAt": FieldValue.serverTimestamp(),
        "lastLogin": null,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Registration submitted. Waiting for admin approval.",
          ),
        ),
      );

      setState(() {
        mobileChecked = false;
        isExistingUser = false;
      });

      nameController.clear();
      companyController.clear();
      addressController.clear();
      areasController.clear();
      pinController.clear();
      confirmPinController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll("Exception: ", ""),
          ),
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> login() async {
    try {
      setState(() => loading = true);

      final query = await FirebaseFirestore.instance
          .collection(Collections.distributors)
          .where('mobile', isEqualTo: mobileController.text.trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception("Distributor not found");
      }

      final doc = query.docs.first;
      final distributor = doc.data();

      if (distributor['isActive'] != true) {
        throw Exception(
          "Your account is awaiting admin approval",
        );
      }

      if (distributor['pin'] != pinController.text.trim()) {
        throw Exception("Invalid PIN");
      }

      await doc.reference.update({
        "lastLogin": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => ResponsiveScaffold(
      distributorId: doc.id,
      distributorData: distributor,
    ),
  ),
);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll("Exception: ", ""),
          ),
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

   @override
  void dispose() {
    mobileController.dispose();
    pinController.dispose();
    nameController.dispose();
    companyController.dispose();
    addressController.dispose();
    areasController.dispose();
    confirmPinController.dispose();

    _controller.dispose();

    super.dispose();
  }

@override
Widget build(BuildContext context) {
  final width = MediaQuery.of(context).size.width;

  final bg1Size = (width * 0.55).clamp(170.0, 260.0);
  final bg2Size = (width * 0.70).clamp(220.0, 320.0);

  return Scaffold(
    body: Stack(
      children: [

        /// Top Right Circle
        AnimatedPositioned(
          duration: const Duration(seconds: 6),
          curve: Curves.easeInOut,
          top: -80,
          right: -60,
          child: Container(
            width: bg1Size,
            height: bg1Size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(.15),
            ),
          ),
        ),

        /// Bottom Left Circle
        AnimatedPositioned(
          duration: const Duration(seconds: 6),
          curve: Curves.easeInOut,
          bottom: -120,
          left: -80,
          child: Container(
            width: bg2Size,
            height: bg2Size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF9A825).withOpacity(.12),
            ),
          ),
        ),

        /// Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF4CAF50).withOpacity(.85),
                const Color(0xFF81C784).withOpacity(.75),
              ],
            ),
          ),
        ),

        Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 430,
                    minWidth: width < 430 ? width - 40 : 430,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 35,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.96),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFFF9A825),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.18),
                          blurRadius: 25,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        /// Logo
                        Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFF9A825),
                                Color(0xFFFFD54F),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Container(
  decoration: const BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.white,
  ),
  child: ClipOval(
    child: Image.asset(
      "assets/images/yaso_login_logo.png",
      fit: BoxFit.cover,
    ),
  ),
),                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Yashodha Distributor",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "Distributor Ordering Portal",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// Mobile Number
                        TextField(
                          controller: mobileController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "Mobile Number",
                            prefixIcon: const Icon(Icons.phone_android),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        if (!mobileChecked)
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                              ),
                              onPressed:
                                  loading ? null : checkMobile,
                              child: loading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child:
                                          CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "CONTINUE",
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.yellowAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                        if (mobileChecked)
                          const SizedBox(height: 10),
                          
if (mobileChecked && isExistingUser) ...[

  TextField(
    controller: pinController,
    obscureText: obscureLoginPin,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: "PIN",
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(
          obscureLoginPin
              ? Icons.visibility_off
              : Icons.visibility,
        ),
        onPressed: () {
          setState(() {
            obscureLoginPin = !obscureLoginPin;
          });
        },
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  ),

  const SizedBox(height: 22),

  SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: loading ? null : login,
      child: loading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              "LOGIN",
              style: TextStyle(
                fontSize: 17,
                color: Colors.yellowAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
    ),
  ),
],

if (mobileChecked && !isExistingUser) ...[

  TextField(
    controller: nameController,
    decoration: InputDecoration(
      labelText: "Distributor Name",
      prefixIcon: const Icon(Icons.person_outline),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  ),

  const SizedBox(height: 14),

  TextField(
    controller: companyController,
    decoration: InputDecoration(
      labelText: "Company Name",
      prefixIcon: const Icon(Icons.business_outlined),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  ),

  const SizedBox(height: 14),

  TextField(
    controller: addressController,
    maxLines: 2,
    decoration: InputDecoration(
      labelText: "Address",
      prefixIcon: const Icon(Icons.location_on_outlined),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  ),

  const SizedBox(height: 14),

 TextField(
  controller: areasController,
  keyboardType: TextInputType.text,
  decoration: InputDecoration(
    labelText: "Service PIN Codes",
    hintText: "Ex: 600116,600056,600089",
    helperText: "Separate multiple PIN codes with commas",
    prefixIcon: const Icon(Icons.pin_drop_outlined),
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  ),
),

  const SizedBox(height: 14),

  TextField(
    controller: pinController,
    obscureText: obscurePin,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: "Create PIN",
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(
          obscurePin
              ? Icons.visibility_off
              : Icons.visibility,
        ),
        onPressed: () {
          setState(() {
            obscurePin = !obscurePin;
          });
        },
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  ),

  const SizedBox(height: 14),

  TextField(
    controller: confirmPinController,
    obscureText: obscureConfirmPin,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: "Confirm PIN",
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(
          obscureConfirmPin
              ? Icons.visibility_off
              : Icons.visibility,
        ),
        onPressed: () {
          setState(() {
            obscureConfirmPin =
                !obscureConfirmPin;
          });
        },
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  ),

  const SizedBox(height: 24),

  SizedBox(
  width: double.infinity,
  height: 54,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2E7D32),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    onPressed: loading ? null : registerDistributor,
    child: loading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : const Text(
            "REGISTER",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.yellowAccent,
            ),
          ),
  ),
),

],

if (mobileChecked) ...[
  const SizedBox(height: 20),

  TextButton.icon(
    onPressed: () {
      setState(() {
        mobileChecked = false;
        isExistingUser = false;

        pinController.clear();
        confirmPinController.clear();
        nameController.clear();
        companyController.clear();
        addressController.clear();
        areasController.clear();
      });
    },
    icon: const Icon(
      Icons.arrow_back_ios_new,
      size: 18,
      color: Color(0xFF2E7D32),
    ),
    label: const Text(
      "Change Mobile Number",
      style: TextStyle(
        color: Color(0xFF2E7D32),
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
],

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}