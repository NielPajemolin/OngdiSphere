import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/features/auth/presentation/cubits/auth/auth_cubit.dart';
import '../colorpalette/color_palette.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Drawer(
      backgroundColor: colors.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // Drawer Header
              DrawerHeader(
                child: Image.asset(
                  'assets/images/kuromi.jpeg',
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.30,
                  fit: BoxFit.contain,
                ),
              ),

              // Profile
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.06),
                child: ListTile(
                  leading: Icon(Icons.person, size: screenWidth * 0.07),
                  title: Text(
                    'P R O F I L E',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: colors.tertiaryText
                      ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ),

              // Done Section
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.06),
                child: ListTile(
                  leading: Icon(Icons.check_box, size: screenWidth * 0.07),
                  title: Text(
                    'D O N E',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: colors.tertiaryText
                      ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/done');
                  },
                ),
              ),
            ],
          ),

          // Logout
          Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.06,
              bottom: screenHeight * 0.03,
            ),
            child: ListTile(
              leading: Icon(Icons.logout, size: screenWidth * 0.07),
              title: Text(
                'L O G O U T',
                style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: colors.tertiaryText
                      ),
                  ),
              onTap: () {
                final authCubit = context.read<AuthCubit>();
                authCubit.logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}