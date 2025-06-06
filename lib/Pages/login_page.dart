import 'package:flutter/material.dart';
import 'package:lab_tracking/Pages/signin_page.dart';
import 'package:lab_tracking/Pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Declare the TextEditingControllers here
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20), // Use const here
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Login Title
                const Text( // Use const here
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24), // Use const here

                // Email text field
                TextField(
                  controller: emailController, // Assign the controller
                  decoration: InputDecoration(
                    hintText: 'Email',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(
                        color: Colors.greenAccent.shade400,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: const BorderSide( // Use const here
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16), // Use const here 


                // Password text field
                TextField(
                  controller: passwordController, // Assign the controller
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(
                        color: Colors.greenAccent.shade400,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: const BorderSide( // Use const here
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32), // Use const here

                // Log In Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade400,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), // Use const here
                  ),
                  onPressed: () async { // Make the function async
                    try {
                      // Get email and password from the text fields
                      String email = emailController.text.trim();
                      String password = passwordController.text.trim();

                      // Optional: Check if email or password is empty
                      if (email.isEmpty || password.isEmpty) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Please enter email and password')), // Use const
                         );
                         return; // Stop here if fields are empty
                      }

                      // Firebase Authentication logic for signing in
                      // This is the part that replaces the TODO
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      // If successful, navigate to the home page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged in successfully!')), // Use const
                      );
                      // Use pushReplacement so the user can't go back to the login page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );

                    } catch (e) {
                      // Handle errors (e.g., user not found, wrong password)
                      print('Error during login: $e'); // Good for debugging

                      String errorMessage = 'Login failed. Please check your credentials.'; // Default message

                      // You can check the type of FirebaseException for more specific error messages
                      if (e is FirebaseAuthException) {
                         switch (e.code) {
                           case 'user-not-found':
                             errorMessage = 'No user found for that email.';
                             break;
                           case 'wrong-password':
                             errorMessage = 'Wrong password provided for that user.';
                             break;
                           case 'invalid-email':
                             errorMessage = 'The email address is invalid.';
                             break;
                           case 'user-disabled':
                             errorMessage = 'This user account has been disabled.';
                             break;
                           // Add more cases as needed
                           default:
                             // Use the message from Firebase if available, otherwise use default
                             errorMessage = e.message ?? errorMessage;
                         }
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $errorMessage')),
                      );
                    }
                  },
                  child: const Text( // Use const here
                    'Log In',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 16), // Use const here

                // Optional: Forgot password or Sign up link
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInPage()), // Use const here
                    );
                  },
                  child: const Text( // Use const here
                    'Don\'t have an account? Sign up',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
