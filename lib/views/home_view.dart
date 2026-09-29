import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/theme.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final ScrollController _scrollController = ScrollController();
  
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _skillsKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  String _activeSection = 'Home';

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewModelProvider.notifier).loadDummyProjects();
    });
  }

  void _scrollTo(GlobalKey key, String sectionName) {
    setState(() => _activeSection = sectionName);
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500), // Fast smooth scroll
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Stack(
        children: [
          // Background blobs for iOS glass effect reflection (STATIC for extreme performance)
          Positioned(
            top: 200, left: 100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.accentColor.withAlpha(40))),
            ),
          ),
          Positioned(
            top: size.height * 1.5, right: 100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(width: 500, height: 500, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withAlpha(30))),
            ),
          ),
          
          // Main Scrollable Content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                SizedBox(height: isDesktop ? 100 : 80), 
                
                // 1. HERO SECTION
                SizedBox(
                  key: _heroKey,
                  height: isDesktop ? size.height * 0.9 : null,
                  child: isDesktop ? _buildDesktopHero() : _buildMobileHero(),
                ),
                
                // 2. ABOUT SECTION
                Container(
                  key: _aboutKey,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 30, vertical: 80),
                  child: _buildAboutSection(isDesktop),
                ),

                // 3. SKILLS SECTION (NEW)
                Container(
                  key: _skillsKey,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 30, vertical: 60),
                  child: _buildSkillsSection(isDesktop),
                ),

                // 4. PROJECTS SECTION (Authentic iOS Glassmorphism)
                Container(
                  key: _projectsKey,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 30, vertical: 100),
                  child: _buildProjectsSection(isDesktop),
                ),

                // 5. CONTACT SECTION
                Container(
                  key: _contactKey,
                  width: double.infinity,
                  color: AppTheme.bgColor, // Changed to dark background
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 30, vertical: 100),
                  child: _buildContactSection(isDesktop),
                ),
              ],
            ),
          ),
          
          // Fixed Navigation Bar (Authentic iOS Glass)
          Positioned(
            top: 0, left: 0, right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.bgColor.withAlpha(180), // iOS Dark Mode Glass
                    border: Border(bottom: BorderSide(color: Colors.white.withAlpha(15), width: 0.5)),
                  ),
                  child: _buildNavBar(isDesktop),
                ),
              ),
            ), 
          ),
        ],
      ),
    );
  }

  // ============== NAVBAR ==============
  Widget _buildNavBar(bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('MAHESH KUMAR SUTHAR', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
              const SizedBox(width: 10),
              if (isDesktop)
                Text('[ FLUTTER DEVELOPER ]', style: GoogleFonts.inter(color: AppTheme.textSecondaryColor, letterSpacing: 1.5, fontSize: 12)),
            ],
          ),
          if (isDesktop)
            Row(
              children: [
                _navLink('Home', _heroKey),
                _navLink('About Me', _aboutKey),
                _navLink('Projects', _projectsKey),
                _navLink('Contact', _contactKey),
              ],
            )
          else
            const Icon(Icons.menu, color: Colors.white),
        ],
      ),
    );
  }

  Widget _navLink(String title, GlobalKey key) {
    final isActive = _activeSection == title;
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: InkWell(
        onTap: () => _scrollTo(key, title),
        hoverColor: Colors.transparent, highlightColor: Colors.transparent, splashColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30), // Pill Shape
            gradient: isActive 
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withAlpha(60), // Liquid highlight
                      Colors.white.withAlpha(5),
                    ],
                  )
                : null,
            border: Border.all(
              color: isActive ? Colors.white.withAlpha(70) : Colors.transparent, 
              width: 1
            ),
            boxShadow: isActive ? [
              BoxShadow(color: AppTheme.accentColor.withAlpha(30), blurRadius: 15, spreadRadius: 2)
            ] : [], // Halka sa lime green glow
          ),
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: isActive ? Colors.white : AppTheme.textSecondaryColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  // ============== HERO SECTION (DESKTOP) ==============
  Widget _buildDesktopHero() {
    return Row(
      children: [
        // Left Side
        Expanded(
          flex: 1,
          child: Container(
            color: AppTheme.accentColor,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned(
                  top: 80, left: 40, right: 40,
                  child: Text(
                    'Hello',
                    style: GoogleFonts.inter(fontSize: 180, fontWeight: FontWeight.w900, color: AppTheme.darkText, height: 0.9, letterSpacing: -10),
                  ).animate().fade(duration: 500.ms), 
                ),
                Positioned(
                  top: 60, right: 50,
                  child: Transform.rotate(
                    angle: 0.15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: AppTheme.darkText, borderRadius: BorderRadius.circular(4)),
                      child: Text('OPEN TO WORK', style: GoogleFonts.inter(color: AppTheme.accentColor, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ).animate().fade(duration: 500.ms, delay: 200.ms),
                ),
                Positioned(
                  bottom: 0, left: 40,
                  child: Container(
                    width: 250, height: 350,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      border: Border.all(color: Colors.white, width: 8),
                    ),
                    child: const Center(child: Text("YOUR PHOTO\n(Change in code)", textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
                  ).animate().fade(duration: 500.ms, delay: 300.ms),
                ),
              ],
            ),
          ),
        ),
        
        // Right Side
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.only(left: 60.0, right: 80.0, top: 120.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "I turn complex app ideas into beautiful, smooth Flutter applications.", 
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w300, height: 1.2),
                ).animate().fade(duration: 500.ms, delay: 100.ms),
                
                const SizedBox(height: 40),
                
                Text(
                  "With experience in building scalable mobile & web apps: focusing on clean UI/UX, robust state management, and pixel-perfect design.", 
                  style: GoogleFonts.inter(color: AppTheme.textSecondaryColor, fontSize: 18, height: 1.6),
                ).animate().fade(duration: 500.ms, delay: 200.ms),
                
                const SizedBox(height: 50),
                
                // 🔴 DATA: RESUME BUTTON 🔴
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    side: const BorderSide(color: AppTheme.accentColor),
                  ),
                  child: Text("DOWNLOAD RESUME", style: GoogleFonts.inter(color: AppTheme.accentColor, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ).animate().fade(duration: 500.ms, delay: 300.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============== HERO SECTION (MOBILE) ==============
  Widget _buildMobileHero() {
    return Column(
      children: [
        Container(
          color: AppTheme.accentColor,
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
          width: double.infinity,
          child: Column(
            children: [
              Text('Hello', style: GoogleFonts.inter(fontSize: 100, fontWeight: FontWeight.w900, color: AppTheme.darkText, height: 0.9, letterSpacing: -5)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.darkText, borderRadius: BorderRadius.circular(4)),
                child: Text('OPEN TO WORK', style: GoogleFonts.inter(color: AppTheme.accentColor, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "I turn complex app ideas into beautiful, smooth Flutter applications.", 
                style: GoogleFonts.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w300, height: 1.2),
              ),
              const SizedBox(height: 20),
              Text(
                "With experience in building scalable mobile & web apps. Based in India.", 
                style: GoogleFonts.inter(color: AppTheme.textSecondaryColor, fontSize: 16, height: 1.6),
              ),
            ],
          ),
        )
      ],
    );
  }

  // ============== ABOUT SECTION ==============
  Widget _buildAboutSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ABOUT ME", style: GoogleFonts.inter(color: AppTheme.accentColor, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 20),
        
        Text(
          "I am Mahesh Kumar Suthar, a passionate Flutter Developer who specializes in building fluid, cross-platform applications. I focus on creating digital experiences that are not only visually stunning but also highly performant. With a strong grasp of state management, MVVM architecture, and pixel-perfect UIs, I love transforming complex ideas into elegant, user-friendly apps.", 
          style: GoogleFonts.inter(color: Colors.white, fontSize: isDesktop ? 32 : 24, fontWeight: FontWeight.w300, height: 1.4),
        ),
      ],
    );
  }

  // ============== SKILLS SECTION (NEW) ==============
  Widget _buildSkillsSection(bool isDesktop) {
    // 🔴 DATA: YOUR SKILLS 🔴
    final skills = ["Flutter", "Dart", "Riverpod", "Firebase", "REST APIs", "Git & GitHub", "Figma", "Appwrite", "Clean Architecture"];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("MY SKILLS & TOOLS", style: GoogleFonts.inter(color: AppTheme.accentColor, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 30),
        Wrap(
          spacing: 15, runSpacing: 15,
          children: skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: Text(skill, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500)),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============== PROJECTS SECTION (AUTHENTIC iOS GLASS) ==============
  Widget _buildProjectsSection(bool isDesktop) {
    final homeState = ref.watch(homeViewModelProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SELECTED PROJECTS", style: GoogleFonts.inter(color: AppTheme.accentColor, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 40),
        
        homeState.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
            : Wrap(
                spacing: 30, runSpacing: 30,
                children: homeState.projects.map((project) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Authentic iOS blur
                      child: Container(
                        width: isDesktop ? 400 : double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(12), // Authentic iOS translucency (very subtle)
                          border: Border.all(color: Colors.white.withAlpha(25), width: 0.5), // Hairline border
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Project Image Placeholder
                            Container(
                              height: 220,
                              width: double.infinity,
                              decoration: BoxDecoration(color: Colors.black.withAlpha(50)),
                              child: const Center(
                                child: Icon(Icons.developer_board, color: Colors.white24, size: 50),
                              ),
                            ),
                            
                            // Text Details
                            Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(project.title, style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  Text(project.description, style: GoogleFonts.inter(color: AppTheme.textSecondaryColor, fontSize: 16, height: 1.5)),
                                  const SizedBox(height: 25),
                                  Row(
                                    children: [
                                      if (project.githubLink != null)
                                        _buildProjectIcon(FontAwesomeIcons.github, project.githubLink!),
                                      if (project.playStoreLink != null)
                                        _buildProjectIcon(FontAwesomeIcons.googlePlay, project.playStoreLink!),
                                      if (project.appStoreLink != null)
                                        _buildProjectIcon(FontAwesomeIcons.apple, project.appStoreLink!),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildProjectIcon(dynamic icon, String url) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: IconButton(
        icon: FaIcon(icon, color: AppTheme.accentColor, size: 20),
        onPressed: () async {
          final uri = Uri.parse(url);
          try {
            await launchUrl(uri);
          } catch (e) {
            debugPrint("Error launching $url");
          }
        },
        hoverColor: AppTheme.accentColor.withAlpha(20),
        splashRadius: 20,
      ),
    );
  }

  // ============== CONTACT SECTION ==============
  Widget _buildContactSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "LET'S BUILD SOMETHING.",
          style: GoogleFonts.inter(color: Colors.white, fontSize: isDesktop ? 60 : 40, fontWeight: FontWeight.w900, letterSpacing: -2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        Text(
          "Have a project idea? Drop a message and let's talk.",
          style: GoogleFonts.inter(color: AppTheme.textSecondaryColor, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 50),
        
        // Premium Contact Form
        Container(
          width: isDesktop ? 600 : double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(5), // Extremely subtle dark glass
            border: Border.all(color: Colors.white.withAlpha(15), width: 1), 
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 40, offset: const Offset(0, 10))
            ],
          ),
          child: Column(
            children: [
              _buildTextField("Your Name", Icons.person_outline, _nameController),
              const SizedBox(height: 25),
              _buildTextField("Your Email", Icons.email_outlined, _emailController),
              const SizedBox(height: 25),
              _buildTextField("Your Message", Icons.message_outlined, _messageController, maxLines: 5),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSending ? null : () async {
                    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty || _messageController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields!")));
                      return;
                    }
                    setState(() => _isSending = true);
                    final success = await ref.read(homeViewModelProvider.notifier).sendContactMessage(
                      _nameController.text, _emailController.text, _messageController.text
                    );
                    setState(() => _isSending = false);
                    if (success) {
                      _nameController.clear();
                      _emailController.clear();
                      _messageController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Message sent successfully! 🚀")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to send message. Please try again.")));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: AppTheme.darkText,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 10,
                    shadowColor: AppTheme.accentColor.withAlpha(100), // Lime green glow
                  ),
                  child: _isSending 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: AppTheme.bgColor, strokeWidth: 2))
                      : Text("SEND MESSAGE", style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),
        
        Text(
          "Or reach out directly at: maheshsuthar1018@gmail.com",
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
        ),
        
        const SizedBox(height: 60),
        
        // 🔴 DATA: SOCIAL LINKS IN FOOTER 🔴
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(FontAwesomeIcons.github),
            const SizedBox(width: 25),
            _buildSocialIcon(FontAwesomeIcons.linkedinIn),
            const SizedBox(width: 25),
            _buildSocialIcon(FontAwesomeIcons.twitter),
            const SizedBox(width: 25),
            _buildSocialIcon(FontAwesomeIcons.instagram),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(dynamic icon) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(10),
      ),
      child: IconButton(
        icon: FaIcon(icon, color: Colors.white70, size: 22),
        onPressed: () {},
        hoverColor: AppTheme.accentColor.withAlpha(40),
        splashRadius: 25,
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      cursorColor: AppTheme.accentColor,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 20, right: 15, top: 2), // Top padding for alignment
          child: Icon(icon, color: Colors.white.withAlpha(100), size: 22),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 60), // Space out icon
        filled: true,
        fillColor: Colors.black.withAlpha(50), // Sleek dark input fields
        contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.accentColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withAlpha(10), width: 1),
        ),
      ),
    );
  }
}
