import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../CustomersWidgets/custom_text_field.dart';
import '../CustomersWidgets/error_dialog.dart';
import '../CustomersWidgets/loading_dialog.dart';
import '../global/global.dart';
import '../mainScreen/home_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();



  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  Position? position;
  List<Placemark>? placeMarks;

  String customerImageUrl = "";
  String completeAddress = "";

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  getCurrentLocation() async
  {
    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    position = newPosition;

    placeMarks = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );

    Placemark pMark = placeMarks![0];

    completeAddress = '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';

    locationController.text = completeAddress;
  }

  Future<void> formValidation() async {
    if (imageXFile == null) {
      showDialog(
        context: context,
        builder: (c) {
          return const ErrorDialog(
            message: "Please select an image.",
          );
        },
      );
    } else {
      if (passwordController.text == confirmPasswordController.text) {
        if (confirmPasswordController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            nameController.text.isNotEmpty &&
            phoneController.text.isNotEmpty &&
            locationController.text.isNotEmpty) {
          // Start uploading image
          showDialog(
            context: context,
            builder: (c) {
              return const LoadingDialog(
                message: "Registering Account",
              );
            },
          );

          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          fStorage.Reference reference = fStorage.FirebaseStorage.instance
              .ref()
              .child("customer")
              .child(fileName);
          fStorage.UploadTask uploadTask =
          reference.putFile(File(imageXFile!.path));
          fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

          try {
            customerImageUrl = await taskSnapshot.ref.getDownloadURL();
            // Save info to Firestore
            authenticateSellerAndSignUp();
          } catch (error) {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (c) {
                return ErrorDialog(
                  message: "Error uploading image: $error",
                );
              },
            );
          }
        } else {
          showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "Please write the complete required info for Registration.",
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Password do not match.",
            );
          },
        );
      }
    }
  }


  void authenticateSellerAndSignUp() async {
    User? currentUser;

    await firebaseAuth
        .createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
        .then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: error.message.toString(),
            );
          });
    });

    if (currentUser != null) {
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);
        //send user to homePage
        Route newRoute = MaterialPageRoute(builder: (c) => const HomeScreen());
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  Future saveDataToFirestore(User currentUser) async {
    FirebaseFirestore.instance.collection("users").doc(currentUser.uid).set({
      "customersUID": currentUser.uid,
      "customersEmail": currentUser.email,
      "customersName": nameController.text.trim(),
      "customerImageUrl": customerImageUrl,
      "phone": phoneController.text.trim(),
      "address": completeAddress,
      "status": "approved",
      "earnings": 0.0,
      "lat": position?.latitude ?? 0.0, // Handle null position gracefully
      "lng": position?.longitude ?? 0.0, // Handle null position gracefully
      "userCart": ['garbageValue'],
    });

    // Save data locally
     sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences!.setString("phone", phoneController.text);
    sharedPreferences!.setString("uid", currentUser.uid);
    sharedPreferences!.setString("address", completeAddress);
    sharedPreferences!.setString("lat", (position?.latitude ?? 0.0).toString());
    sharedPreferences!.setString("email", currentUser.email.toString());
    sharedPreferences!.setString("name", nameController.text.trim());
    sharedPreferences!.setString("customerImageUrl", customerImageUrl);
    sharedPreferences!.setStringList("userCart", ['garbageValue']);
  }






  @override
  Widget build(BuildContext context) {
    List images = ["google.png", "facebook.png", "twitter.png"];

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: Column(
          children: [
            Container(
              width: w,
              height: h * 0.4,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage("images/log.png"),
                fit: BoxFit.cover,
              )),
            ),
            Container(

              margin: const EdgeInsets.only(left: 20, right: 20),
              width: w,
              child: const Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: [],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    _getImage();
                  },
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.10,
                    backgroundColor: Colors.black87,
                    backgroundImage: imageXFile == null
                        ? null
                        : FileImage(File(imageXFile!.path)),
                    child: imageXFile == null
                        ? Icon(
                            Icons.add_photo_alternate,
                            size: MediaQuery.of(context).size.width * 0.10,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: nameController,
                        data: Icons.person,
                        hintText: "Enter your Full Name",
                        isObscure: false,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: emailController,
                        data: Icons.email,
                        hintText: "Enter your Email",
                        isObscure: false,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: phoneController,
                        data: Icons.phone_android,
                        hintText: "Enter your Phone Number",
                        isObscure: false,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: passwordController,
                        data: Icons.password,
                        hintText: "Enter your Password",
                        isObscure: true,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: confirmPasswordController,
                        data: Icons.password_rounded,
                        hintText: "Confirm your Password",
                        isObscure: true,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: locationController,
                        data: Icons.location_city,
                        hintText: "Enter your Address",
                        isObscure: false,
                        enabled: true,
                      ),
                      const SizedBox(height: 20),
                      Container(
                          width: 400,
                          height: 40,
                          alignment: Alignment.center,
                          child: ElevatedButton.icon(
                              label:  const Text(
                             ("Get my current location")
                            ,
                              style: TextStyle(color: Colors.white),
                            ),
                            icon: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              getCurrentLocation();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black45,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                )),
                          ))
                    ],
                  ),
                ),
                SizedBox(height: w * 0.08),
                SizedBox(
                  width: 150, // Set the desired width
                  child: ElevatedButton(
                    onPressed: () {
                      formValidation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black45,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Next",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: w * 0.08),
                RichText(
                    text: const TextSpan(
                  text: "Sign up using one of the following methods:",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                )),
                const SizedBox(height: 23),
                Wrap(
                  children: List<Widget>.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              AssetImage("images/" + images[index]),
                        ),
                      ),
                    );
                  }),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
