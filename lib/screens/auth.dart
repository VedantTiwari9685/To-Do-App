import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/widgets/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  // Move these variables out of the build method to make them instance variables.
  bool _obscurePassText = true;

  void _obscurePassTextChange() {
    setState(() {
      _obscurePassText = !_obscurePassText;
    });
  }

  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredUsername = '';
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _reEnteredPassword = '';
  File? _selectedImage;
  bool _isAuthenticating = false;

  bool _isLogin = true;
  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || (!_isLogin && _selectedImage == null)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin
              ? "Please check the Email and Password are entered correctly."
              : "Please check the Email and Password are entered and also the profile image is picked."),
        ),
      );
    }
    _formKey.currentState!.save();
    if (_isLogin ||
        (!_isLogin &&
            _selectedImage != null &&
            _enteredPassword == _reEnteredPassword)) {
      try {
        setState(() {
          _isAuthenticating = true;
        });
        if (_isLogin) {
          // Log users in

          await _firebase.signInWithEmailAndPassword(
              email: _enteredEmail, password: _enteredPassword);
        } else {
          // Create new user.

          final userCredential = await _firebase.createUserWithEmailAndPassword(
              email: _enteredEmail, password: _enteredPassword);

          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child('${userCredential.user!.uid}.jpg');

          await storageRef.putFile(_selectedImage!);
          final imageURL = await storageRef.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'name': _enteredName,
            'email': _enteredEmail,
            'username': _enteredUsername,
            'image_url': imageURL,
          });
        }
      }
      // This can throw error if email already exists or something else.
      on FirebaseAuthException catch (error) {
        setState(() {
          _isAuthenticating = false;
        });
        if (error.code == 'email-already-in-use') {
          //..
        }
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message ?? "Authentication failed."),
            ),
          );
        }
      }
    } else if (!_isLogin && _enteredPassword != _reEnteredPassword) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords are not matching."),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Make sure you set an image."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLogin)
                Container(
                  margin: const EdgeInsets.only(
                    top: 30,
                    bottom: 30,
                    left: 20,
                    right: 20,
                  ),
                  width: 200,
                  child: Image.asset('assets/images/todo.png'),
                ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            Column(
                              children: [
                                const SizedBox(
                                  height: 16,
                                ),
                                UserImagePicker(
                                  onPickImage: (pickedImage) {
                                    _selectedImage = pickedImage;
                                  },
                                ),
                              ],
                            ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Full Name",
                              ),
                              autocorrect: false,
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a valid Name.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredName = value!;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Email Address",
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid Email Address.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Username",
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                final RegExp usernameRegExp =
                                    RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]{3,}$');

                                // Check if the value is null or less than 4 characters after trimming
                                if (value == null || value.trim().isEmpty) {
                                  return 'Username is required';
                                } else if (value.trim().length < 4) {
                                  return 'Username must be at least 4 characters long';
                                }
                                // Check if the username does not match the allowed pattern
                                else if (!usernameRegExp
                                    .hasMatch(value.trim())) {
                                  return 'Invalid username. Only letters, numbers, and _ are allowed, and it must not start with a number.';
                                }
                                return null; // Return null if the validation passes
                              },
                              onSaved: (value) {
                                _enteredUsername = value!;
                              },
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: "Password",
                                  ),
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.none,
                                  obscureText: _obscurePassText,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().length < 6) {
                                      return 'Password must be at least 6 characters long.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _enteredPassword = value!;
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: _obscurePassTextChange,
                                icon: _obscurePassText
                                    ? const Icon(Icons.visibility_off)
                                    : const Icon(Icons.visibility),
                              ),
                            ],
                          ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Re-Enter Password",
                              ),
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Entered passwords are not matching.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _reEnteredPassword = value!;
                              },
                            ),
                          const SizedBox(height: 12),
                          if (_isAuthenticating)
                            const Column(
                              children: [
                                SizedBox(
                                  height: 15,
                                ),
                                CircularProgressIndicator()
                              ],
                            ),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(_isLogin ? "Login" : 'Sign Up'),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin
                                    ? "Create an account."
                                    : "I already have an account."))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
