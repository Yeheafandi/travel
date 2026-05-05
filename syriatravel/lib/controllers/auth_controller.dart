import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/models/user_model.dart';
import 'package:syriatravel/core/services/storage_service.dart'; 
import 'package:syriatravel/routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  
  var name = ''.obs;
  var phone = ''.obs;
  var email = ''.obs;

  @override
  void onInit() {
    super.onInit();
    name.value = StorageService.getUserName();
  }

  Future<void> fetchUserData() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        name.value = doc['name'] ?? "";
        phone.value = doc['phone'] ?? "";
        email.value = doc['email'] ?? "";
        
        await StorageService.saveUserName(name.value);
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> register(String email, String password, String role) async {
    try {
      isLoading.value = true;
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      UserModel newUser = UserModel(
        uid: cred.user!.uid,
        email: email.trim(),
        name: name.value,
        phone: phone.value,
        role: role,
      );

      await _firestore.collection('users').doc(cred.user!.uid).set(newUser.toMap());

      await StorageService.saveUserRole(role);
      await StorageService.saveUserName(name.value); 

      _routeUser(role);
    } catch (e) {
      _showErrorSnackBar("خطأ أثناء التسجيل", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String emailInput, String password) async {
    try {
      isLoading.value = true;
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: emailInput.trim(),
        password: password.trim(),
      );

      DocumentSnapshot doc = await _firestore.collection('users').doc(cred.user!.uid).get();
      
      String role = doc['role'];
      String fetchedName = doc['name'] ?? "";

      await StorageService.saveUserRole(role);
      await StorageService.saveUserName(fetchedName);
      
      name.value = fetchedName;

      _routeUser(role);
    } catch (e) {
      _showErrorSnackBar("خطأ", "البريد أو كلمة المرور غير صحيحة");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      await StorageService.clearAll(); 
      name.value = '';
      phone.value = '';
      email.value = '';
      Get.offAllNamed(AppRoutes.roleSelection);
    } catch (e) {
      _showErrorSnackBar("خطأ", "فشل تسجيل الخروج");
    }
  }

  void _routeUser(String role) {
    if (role == 'driver') {
      Get.offAllNamed(AppRoutes.driverHome);
    } else {
      Get.offAllNamed(AppRoutes.mainWrapper);
    }
  }

  void _showErrorSnackBar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
    );
  }
}