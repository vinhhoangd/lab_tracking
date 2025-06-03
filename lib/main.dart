import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Wave animation controller
    _waveController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 4)
    )..repeat();
    
    // Fade animation controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Scale animation controller
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut)
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut)
    );
    
    // Start animations with delays
    Future.delayed(const Duration(milliseconds: 500), () {
      _fadeController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Animated background waves
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                painter: EnhancedWavePainter(progress: _waveController.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),
          
          // Main content with fade and scale animations
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Positioned(
                        bottom: 120,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                          
                            
                            const SizedBox(height: 32),
                            
                            // Welcome text
                            const Text(
                              'Welcome',
                              style: TextStyle(
                                fontSize: 32, 
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Subtitle
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                "Biomedical's Tracking App",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16, 
                                  color: Colors.grey,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 48),
                            
                            // Get started button with enhanced styling
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.greenAccent.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent.shade400,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 48, 
                                    vertical: 16
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  // Add haptic feedback
                                  // HapticFeedback.lightImpact();
                                  // Navigate to main screen
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 18),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Login button
                            TextButton(
                              onPressed: () {
                                // Navigate to login screen
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24, 
                                  vertical: 12
                                ),
                              ),
                              child: const Text(
                                'Already have an account? Login',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          
          // Loading indicator at the bottom
          Positioned(
            bottom: 40,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 8,
                        height: 8 + 
                          4 * sin((_waveController.value * 2 * pi) + (index * 0.5)),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EnhancedWavePainter extends CustomPainter {
  final double progress;
  
  EnhancedWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Create multiple wave layers for depth
    _drawWave(canvas, size, progress, Colors.greenAccent.withOpacity(0.1), 60.0, 0.8);
    _drawWave(canvas, size, progress + 0.3, Colors.greenAccent.withOpacity(0.15), 80.0, 1.0);
    _drawWave(canvas, size, progress + 0.6, Colors.greenAccent.withOpacity(0.2), 100.0, 1.2);
    
    // Add particle effect
    _drawParticles(canvas, size, progress);
  }
  
  void _drawWave(Canvas canvas, Size size, double progress, Color color, double amplitude, double frequency) {
    final path = Path();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2.5;
    path.moveTo(0, centerY);

    for (double i = 0; i <= size.width; i += 2) {
      final y = centerY + sin(i / 40 * frequency + progress * 2 * pi) * amplitude;
      path.lineTo(i, y);
    }

    canvas.drawPath(path, paint);
  }
  
  void _drawParticles(Canvas canvas, Size size, double progress) {
    final paint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    final random = Random(42); // Fixed seed for consistent animation
    
    for (int i = 0; i < 20; i++) {
      final x = (random.nextDouble() * size.width + progress * 100) % (size.width + 50);
      final y = size.height * 0.3 + random.nextDouble() * size.height * 0.4;
      final radius = 1.0 + random.nextDouble() * 2;
      
      canvas.drawCircle(
        Offset(x, y), 
        radius * (0.5 + 0.5 * sin(progress * 2 * pi + i)), 
        paint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}