import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/app/di/auth_injection.dart';
import 'package:front_end/app/routes/routes.dart';
import 'package:front_end/app/theme/colors.dart';
import 'package:front_end/core/helper/rive_login_controller.dart';
import 'package:front_end/features/auth/presentation/blocs/login_bloc.dart';
import 'package:front_end/features/auth/presentation/blocs/login_event.dart';
import 'package:front_end/features/auth/presentation/blocs/login_state.dart';
import 'package:front_end/features/auth/presentation/widgets/gradient_elevated_button.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final riveController = RiveLoginController(
    animationPath: 'assets/animations/auth/login_bear.riv',
  );

  // Animation controller cho line fill
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

  // Để biết TextField nào đang focus
  FocusNode emailFocus = FocusNode();
  FocusNode passFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    riveController.init().then((_) => setState(() {}));

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );

    // lắng nghe focus
    emailFocus.addListener(() {
      if (emailFocus.hasFocus) {
        _lineController.forward(from: 0);
      }
    });

    passFocus.addListener(() {
      if (passFocus.hasFocus) {
        _lineController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _lineController.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    super.dispose();
  }

  void onLoginPressed() {
    context.read<LoginBloc>().add(
      LoginSubmitted(emailController.text, passController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorManager.background,
      body: Center(
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess || state is LoginTokenFound) {
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text('Welcome, ${state.user.fullName}')),
              // );
              if (state is LoginSuccess) {
                riveController.login(true);
              }
              context.go(Routes.main);
            } else if (state is LoginFailure) {
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text(state.message)),
              // );
              riveController.login(false);
            }
          },
          builder: (context, state) {
            if (state is LoginInitial) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<LoginBloc>().add(CheckSavedToken());
              });
            }
            
            if (state is LoginLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (riveController.artboard != null)
                    SizedBox(
                      width: size.width * 0.7,
                      height: 250,
                      child: Rive(artboard: riveController.artboard!),
                    ),
                  const SizedBox(height: 40),

                  // Email Field
                  _buildAnimatedTextField(
                    controller: emailController,
                    label: "Email",
                    focusNode: emailFocus,
                    onTap: riveController.lookAround,
                    onChanged: riveController.moveEyes,
                  ),
                  const SizedBox(height: 24),

                  // Password Field
                  _buildAnimatedTextField(
                    controller: passController,
                    label: "Password",
                    obscure: true,
                    focusNode: passFocus,
                    onTap: riveController.handsUpOnEyes,
                  ),

                  const SizedBox(height: 40),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: GradientElevatedButton(
                      onPressed: onLoginPressed,
                      borderRadius: BorderRadius.circular(16),
                      gradient: ColorManager.primary,
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required FocusNode focusNode,
    bool obscure = false,
    Function()? onTap,
    Function(String)? onChanged,
  }) {
    return AnimatedBuilder(
      animation: _lineAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            TextFormField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscure,
              onTap: onTap,
              onChanged: onChanged,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                labelText: label,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                labelStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                floatingLabelStyle: const TextStyle(
                  color: ColorManager.primarySolid,
                  fontWeight: FontWeight.w600,
                  fontSize:
                      20, 
                  height: 0.8, 
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                border: InputBorder.none,
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent, width: 0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              cursorColor: ColorManager.primarySolid,
            ),

            // Animated fill line
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                painter: _LinePainter(
                  progress: focusNode.hasFocus ? _lineAnimation.value : 0,
                ),
                child: Container(height: 2),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LinePainter extends CustomPainter {
  final double progress;
  _LinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ColorManager.primarySolid
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final lineLength = size.width * progress;
    canvas.drawLine(Offset(0, 0), Offset(lineLength, 0), paint);
  }

  @override
  bool shouldRepaint(_LinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
