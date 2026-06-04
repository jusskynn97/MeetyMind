import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:front_end/features/auth/presentation/blocs/auth_event.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        onPressed: () {
          context.read<AuthBloc>().add(LogoutRequested());
        },
      ),
    );
  }
}
