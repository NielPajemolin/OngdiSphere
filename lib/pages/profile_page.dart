import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/features/auth/presentation/cubits/auth/auth_cubit.dart';
import '../colorpalette/color_palette.dart';
import '../components/my_button.dart'; 

class ProfilePage extends StatelessWidget {
   ProfilePage({super.key});

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;

    // Get current user from AuthCubit
    final user = context.read<AuthCubit>().currenUser;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.primary,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(
            color: colors.primaryText,
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: screenWidth * 0.18,
              backgroundColor: colors.primary,
              child: Icon(
                Icons.person,
                color: colors.primaryText,
                size: screenWidth * 0.18,
              ),
            ),

            SizedBox(height: screenWidth * 0.05),

            // User name

            SizedBox(height: screenWidth * 0.05),

            // Profile info card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: colors.secondary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Account Information",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: colors.primaryText,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Name
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.person, color: colors.primary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Name: ${user?.name ?? 'No name'}",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: colors.primaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Email
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.email, color: colors.primary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Email: ${user?.email ?? 'No email'}",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: colors.primaryText,
                          ),
                          softWrap: true, // allows wrapping for long emails
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),


            const Spacer(),

            // ⭐ Use your custom MyButton here
            MyButton(
              label: "Edit Profile",
              onPressed: () {
               
              },
            ),


            SizedBox(height: screenWidth * 0.05),
          ],
        ),
      ),
    );
  }
}
