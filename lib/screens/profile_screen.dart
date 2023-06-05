// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letschat/auth/login_screen.dart';
import 'package:letschat/models/chat_user.dart';
import '../api/apis.dart';
import '../helpers/dialog.dart';
import '../main.dart';

// profile screen to show signed in user info

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Profile Screen'),
          ),

          // floating button to log out
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.red,
              onPressed: () async {
                // for showing progress bar
                Dialogs.showProgessBar(context);
                // to make the user to appear offline
                await APIs.updateActiveStatus(false);
                // sign out from app
                await APIs.auth.signOut().then((value) => {
                      GoogleSignIn().signOut().then((value) {
                        // for hiding progress bar
                        Navigator.pop(context);
                        // for moving to homescreen
                        Navigator.pop(context);
                        // to reinstantiate to authentication
                        APIs.auth = FirebaseAuth.instance;
                        // replacing homescreen with login screen
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()));
                      }),
                    });
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
            ),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // for adding  some space
                    SizedBox(width: mq.width, height: mq.height * 0.03),
                    // user profile picture
                    Stack(
                      // profile picture
                      children: [
                        _image != null
                            ?
                            // local image
                            ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * 0.3),
                                child: Image.file(
                                  File(_image!),
                                  width: mq.height * 0.2,
                                  height: mq.height * 0.2,
                                  fit: BoxFit.cover,
                                ),
                              )
                            :
                            // image from server
                            ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * 0.3),
                                child: CachedNetworkImage(
                                  width: mq.height * 0.2,
                                  height: mq.height * 0.2,
                                  fit: BoxFit.fill,
                                  imageUrl: widget.user.image,
                                  // placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                          child: Icon(CupertinoIcons.person)),
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            elevation: 1,
                            onPressed: () {
                              _showBottomSheet();
                            },
                            color: Colors.white,
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // for adding  some space
                    SizedBox(width: mq.width, height: mq.height * 0.03),
                    Text(
                      widget.user.email,
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                    // for adding  some space
                    SizedBox(width: mq.width, height: mq.height * 0.05),
                    // username
                    TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => widget.user.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.person, color: Colors.blue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        label: const Text("Name"),
                        hintText: "e.g, Happy Singh",
                      ),
                    ),

                    // for adding  some space
                    SizedBox(width: mq.width, height: mq.height * 0.02),
                    // about
                    TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => widget.user.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.info_outline, color: Colors.blue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        label: const Text("About"),
                        hintText: "e.g, Feeling Happy",
                      ),
                    ),

                    // for adding  some space
                    SizedBox(width: mq.width, height: mq.height * 0.02),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          minimumSize: Size(mq.width * 0.4, mq.height * 0.04)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo();
                          Dialogs.showSnackBar(context, "Profile Updated");
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("Update"),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }

  // bottom sheet  for  picking a profile picture for user
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            padding: EdgeInsets.only(
                top: mq.height * 0.03, bottom: mq.height * 0.05),
            shrinkWrap: true,
            children: [
              // pick profile picture label
              const Text(
                "Pick Profile Image",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              // for adding  some space
              SizedBox(
                height: mq.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                          shape: const CircleBorder()),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log("ImagePath: ${image.path}--MIME: ${image.mimeType}");

                          setState(() {
                            _image = image.path;
                          });
                          // for saving the profile picture
                          APIs.updateProfilePicture(File(_image!));
                          // for hiding the bottomSheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/add-image.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                          shape: const CircleBorder()),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log("ImagePath: ${image.path}");

                          setState(() {
                            _image = image.path;
                          });
                          // for saving the profile picture
                          APIs.updateProfilePicture(File(_image!));
                          // for hiding the bottomSheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera.png'))
                ],
              )
            ],
          );
        });
  }
}
