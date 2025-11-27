import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../settings/presentation/providers/user_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with TickerProviderStateMixin {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _schoolController = TextEditingController();
  
  int _currentPage = 0;
  bool _isLoading = false;

  // Animation Controllers
  late final AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _classController.dispose();
    _schoolController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubicEmphasized,
      );
      setState(() => _currentPage++);
    } else {
      _submit();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubicEmphasized,
      );
      setState(() => _currentPage--);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(userNotifierProvider.notifier).saveUser(
        name: _nameController.text.trim(),
        grade: _classController.text.trim(),
        email: '', // Email already collected during signup
        schoolName: _schoolController.text.trim().isEmpty ? null : _schoolController.text.trim(),
      );

      if (mounted) {
        context.go('/focus');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Animated Background
          _buildAnimatedBackground(),

          // 2. Glass Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.white.withOpacity(0.1)),
            ),
          ),

          // 3. Content
          SafeArea(
            child: Column(
              children: [
                const Gap(20),
                // Progress Indicator
                _buildProgressIndicator(),
                
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStep1Identity(),
                        _buildStep2Education(),
                        _buildStep3Contact(),
                      ],
                    ),
                  ),
                ),
                
                // Navigation Buttons
                _buildNavigationButtons(),
                const Gap(20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: const Color(0xFFF3F4F6)), // Base color
            // Orb 1
            Positioned(
              top: -100 + (_backgroundController.value * 50),
              left: -50 + (_backgroundController.value * 30),
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xFF6A11CB), Colors.transparent],
                  ),
                ),
              ),
            ),
            // Orb 2
            Positioned(
              bottom: -50 - (_backgroundController.value * 50),
              right: -100 - (_backgroundController.value * 30),
              child: Container(
                width: 400,
                height: 400,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xFF2575FC), Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentPage;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF6A11CB) : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
                boxShadow: isActive ? [
                  BoxShadow(color: const Color(0xFF6A11CB).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))
                ] : [],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1Identity() {
    return _OnboardingStep(
      title: "Who are you?",
      subtitle: "Let's start with your name.",
      heroWidget: const _Hero3DElement(icon: Icons.person_rounded, color: Color(0xFF6A11CB)),
      children: [
        _buildTextField(
          controller: _nameController,
          label: "Full Name",
          icon: Icons.person_outline,
          autoFocus: true,
        ),
      ],
    );
  }

  Widget _buildStep2Education() {
    return _OnboardingStep(
      title: "Where do you study?",
      subtitle: "Help us tailor your experience.",
      heroWidget: const _Hero3DElement(icon: Icons.school_rounded, color: Color(0xFF2575FC)),
      children: [
        _buildTextField(
          controller: _classController,
          label: "Class / Grade",
          icon: Icons.grade_outlined,
        ),
        const Gap(16),
        _buildTextField(
          controller: _schoolController,
          label: "School Name (Optional)",
          icon: Icons.location_city_outlined,
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildStep3Contact() {
    return _OnboardingStep(
      title: "Almost there!",
      subtitle: "Let's personalize your learning journey.",
      heroWidget: const _Hero3DElement(icon: Icons.psychology_rounded, color: Color(0xFFFF6D6D)),
      children: [
        Text(
          "We're excited to help you learn better! Your profile is almost complete.",
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.grey[700],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          if (_currentPage > 0)
            TextButton(
              onPressed: _prevPage,
              child: Text(
                "Back",
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[700]),
              ),
            )
          else
            const SizedBox(width: 60),

          // Next/Finish Button
          FilledButton(
            onPressed: _isLoading ? null : _nextPage,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6A11CB),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              shadowColor: const Color(0xFF6A11CB).withOpacity(0.5),
            ),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentPage == 2 ? "Get Started" : "Next",
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Gap(8),
                      Icon(_currentPage == 2 ? Icons.check : Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = true,
    TextInputType? inputType,
    bool autoFocus = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      autofocus: autoFocus,
      keyboardType: inputType,
      validator: validator ?? (v) => isRequired && (v == null || v.isEmpty) ? 'Required' : null,
      style: GoogleFonts.inter(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6A11CB)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6A11CB), width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }
}

class _OnboardingStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget heroWidget;
  final List<Widget> children;

  const _OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.heroWidget,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          heroWidget,
          const Gap(40),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF333333)),
            textAlign: TextAlign.center,
          ).animate().fadeIn().slideY(begin: 0.3, end: 0),
          const Gap(8),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3, end: 0),
          const Gap(40),
          ...children,
        ],
      ),
    );
  }
}

class _Hero3DElement extends StatefulWidget {
  final IconData icon;
  final Color color;

  const _Hero3DElement({required this.icon, required this.color});

  @override
  State<_Hero3DElement> createState() => _Hero3DElementState();
}

class _Hero3DElementState extends State<_Hero3DElement> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(math.sin(_controller.value * 2 * math.pi) * 0.2) // Gentle sway
            ..rotateX(math.cos(_controller.value * 2 * math.pi) * 0.1),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                  spreadRadius: 5,
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey[100]!,
                ],
              ),
            ),
            child: Center(
              child: Icon(
                widget.icon,
                size: 60,
                color: widget.color,
              ),
            ),
          ),
        );
      },
    );
  }
}
