import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techladder/core/theme/color_tokens.dart';
import 'package:techladder/core/widgets/common_widgets.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.bgBase,
      appBar: AppBar(
        backgroundColor: ColorTokens.bgBase,
        title: Text('Community',
            style: GoogleFonts.syne(color: ColorTokens.textPrimary, fontWeight: FontWeight.w700, fontSize: 20)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ColorTokens.accentCyan,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 2,
          labelColor: ColorTokens.accentCyan,
          unselectedLabelColor: ColorTokens.textSecond,
          labelStyle: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Interview Exp.'),
            Tab(text: 'Jobs & Startups'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _InterviewExpTab(),
          _JobsTab(),
        ],
      ),
    );
  }
}

// ─── Data models ──────────────────────────────────────────────────────────────

class _InterviewExp {
  final String company, role, date, preview, fullText, difficulty, upvotes;
  final bool isSelected;
  const _InterviewExp({
    required this.company,
    required this.role,
    required this.date,
    required this.preview,
    required this.fullText,
    required this.difficulty,
    required this.upvotes,
    this.isSelected = false,
  });
}

class _Job {
  final String company, role, exp, salary, location, url;
  const _Job({
    required this.company,
    required this.role,
    required this.exp,
    required this.salary,
    required this.location,
    required this.url,
  });
}

// ─── Interview Experiences Tab ────────────────────────────────────────────────

class _InterviewExpTab extends StatelessWidget {
  const _InterviewExpTab();

  static const _experiences = [
    _InterviewExp(
      company: 'Amazon', role: 'SDE-1', date: 'Jan 2025',
      preview: 'Had 5 rounds — 2 coding, 1 system design, 1 bar raiser, 1 manager. Focus was on LP (Leadership Principles) and DSA.',
      fullText: 'Round 1 (Online Assessment): 2 coding questions. One was a variation of Number of Islands, the other was DP (Coin Change 2). Both solved with passing test cases.\n\nRound 2 (DSA): Interviewer asked a graphing question involving topological sort. Was asked to write working Java code and dry run it. Solved in 35 mins.\n\nRound 3 (System Design / LLD): Design a parking lot. Heavily focused on Design Patterns. I used Strategy for pricing and Singleton for the DB connection.\n\nRound 4 (Bar Raiser): Heavy leadership principles (LP). Real-life scenarios about handling tight deadlines and disagreeing with managers. They want the STAR method (Situation, Task, Action, Result).\n\nRound 5 (Managerial): Mostly resume grilling and more LP. Very friendly.',
      difficulty: 'Hard', upvotes: '142', isSelected: true,
    ),
    _InterviewExp(
      company: 'Google', role: 'Software Engineer L3', date: 'Mar 2025',
      preview: 'Phone screen + 5 onsite rounds. Heavy focus on algorithms and data structures. One round dedicated to Googleyness.',
      fullText: 'Phone Screen: 45 min Google Meet. Question was a twist on sliding window maximum. Got the optimal O(N) solution using a Deque.\n\nOnsites:\n1. DSA: Hard level tree problem. Needed to find LCA of deep nodes and return path sum.\n2. DSA: Graphs and BFS. Essentially a "word ladder" variant but with matrix cells.\n3. LLD: Design an autocomplete system (Trie based). Heavily discussed memory constraints.\n4. Googleyness: Behavioral questions. "Tell me about a time you mentored someone."\n5. DSA: DP problem resembling Longest Increasing Subsequence but with 2D bounds. Struggled here but interviewer helped.',
      difficulty: 'Hard', upvotes: '98',
    ),
    _InterviewExp(
      company: 'Microsoft', role: 'SDE-1', date: 'Feb 2025',
      preview: 'Three technical rounds + one HR round. Questions were medium-level DSA, mostly from trees and graphs.',
      fullText: 'Round 1 (Codility): 3 questions, 90 mins. Array manipulation, string parsing, and a basic graph problem. \n\nRound 2 (Technical): 1 hr. Reverse a linked list in chunks of K, and a variation of Two Sum. Very straightforward. \n\nRound 3 (System Design): Design a URL shortener like TinyURL. Focus was on hashing algorithms and scaling the database.\n\nRound 4 (HR): Standard behavioral questions and discussing my past internship projects. Selected!',
      difficulty: 'Medium', upvotes: '87',
    ),
    _InterviewExp(
      company: 'TCS', role: 'System Engineer', date: 'Apr 2025',
      preview: 'Online test (NQT) + technical interview. Focus on OOPs, DBMS, and C++ basics.',
      fullText: 'TCS NQT: Standard aptitude, analytical, and logical reasoning. Followed by 2 coding questions (One string manipulation, one basic math).\n\nTechnical Interview (40 mins): Asked about my final year project. Then deep-dived into OOPs concepts (Polymorphism, Abstraction). Asked me to write SQL queries for left joins and inner joins. Very smooth process, clear basics will get you through.',
      difficulty: 'Easy', upvotes: '54',
    ),
    _InterviewExp(
      company: 'Groww', role: 'Backend Developer', date: 'Mar 2025',
      preview: 'Focus heavily on Spring Boot, microservices architecture, and SQL tricky queries.',
      fullText: 'Round 1: Machine coding round. Had to build a mini wallet system in Java Spring Boot within 2 hours. Focus on concurrency handling.\n\nRound 2: System design. Designing a stock broker system. Discussed exactly how to handle high-frequency trades and message queues (Kafka vs RabbitMQ).\n\nRound 3: Hiring Manager. Mostly behavioral and discussing how to handle DB migrations without downtime.',
      difficulty: 'Hard', upvotes: '112',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: _experiences.length,
      itemBuilder: (context, i) {
        final exp = _experiences[i];
        return TLCard(
          borderColor: exp.isSelected ? ColorTokens.accentCyan : null,
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: ColorTokens.bgElevated,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (ctx) => DraggableScrollableSheet(
                initialChildSize: 0.7,
                maxChildSize: 0.9,
                minChildSize: 0.5,
                expand: false,
                builder: (ctx, scrollController) => ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: ColorTokens.bgBorder, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(children: [
                      Expanded(
                        child: Text('${exp.company} - ${exp.role}', 
                          style: GoogleFonts.syne(color: ColorTokens.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                      ),
                      DifficultyBadge(exp.difficulty),
                    ]),
                    const SizedBox(height: 8),
                    Text('Date: ${exp.date}  ·  👍 ${exp.upvotes} upvotes', style: GoogleFonts.ibmPlexSans(color: ColorTokens.textSecond, fontSize: 13)),
                    const SizedBox(height: 24),
                    Text('Experience', style: GoogleFonts.syne(color: ColorTokens.accentCyan, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Text(exp.fullText, style: GoogleFonts.ibmPlexSans(color: ColorTokens.textPrimary, fontSize: 14, height: 1.6)),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTokens.accentCyan,
                        foregroundColor: ColorTokens.bgBase,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Close', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(exp.company,
                      style: GoogleFonts.syne(color: ColorTokens.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                  Text('${exp.role} · ${exp.date}',
                      style: GoogleFonts.ibmPlexSans(color: ColorTokens.textSecond, fontSize: 12)),
                ]),
                const Spacer(),
                DifficultyBadge(exp.difficulty),
              ]),
              const SizedBox(height: 10),
              Text(exp.preview,
                  style: GoogleFonts.ibmPlexSans(color: ColorTokens.textSecond, fontSize: 13, height: 1.5),
                  maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.thumb_up_rounded, color: ColorTokens.textSecond, size: 14),
                const SizedBox(width: 4),
                Text(exp.upvotes, style: GoogleFonts.ibmPlexSans(color: ColorTokens.textSecond, fontSize: 12)),
                const Spacer(),
                Text('Read more →', style: GoogleFonts.ibmPlexSans(color: ColorTokens.accentCyan, fontSize: 12)),
              ]),
            ],
          ),
        ).animate(delay: (i * 50).ms).fadeIn().slideY(begin: 0.04);
      },
    );
  }
}

// ─── Jobs & Startups Tab ──────────────────────────────────────────────────────

class _JobsTab extends StatelessWidget {
  const _JobsTab();

  static const _locations = ['All', 'Bangalore', 'Hyderabad', 'Remote', 'Mumbai', 'Pune'];

  static const _jobs = [
    _Job(company: 'Zomato', role: 'Software Engineer', exp: '0-2 yrs', salary: '12-18 LPA', location: 'Bangalore', url: 'https://www.linkedin.com/jobs/search/?keywords=zomato%20software%20engineer'),
    _Job(company: 'PhonePe', role: 'Backend Engineer', exp: '1-3 yrs', salary: '15-25 LPA', location: 'Bangalore', url: 'https://careers.phonepe.com/'),
    _Job(company: 'Razorpay', role: 'Full Stack Engineer', exp: '0-2 yrs', salary: '18-30 LPA', location: 'Bangalore', url: 'https://razorpay.com/jobs/'),
    _Job(company: 'Meesho', role: 'SDE-1', exp: '0-2 yrs', salary: '20-28 LPA', location: 'Bangalore', url: 'https://meesho.io/jobs'),
    _Job(company: 'Groww', role: 'Software Developer', exp: '0-2 yrs', salary: '16-22 LPA', location: 'Bangalore', url: 'https://groww.in/open-positions'),
    _Job(company: 'CRED', role: 'Android Engineer', exp: '1-3 yrs', salary: '20-35 LPA', location: 'Bangalore', url: 'https://careers.cred.club/'),
    _Job(company: 'Zepto', role: 'Backend Developer', exp: '0-2 yrs', salary: '12-20 LPA', location: 'Mumbai', url: 'https://www.linkedin.com/company/zepto-app/jobs/'),
    _Job(company: 'Remote Startup', role: 'React Developer', exp: '1-3 yrs', salary: '10-18 LPA', location: 'Remote', url: 'https://remoteok.com/remote-react-jobs'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Location filters
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: _locations.length,
            itemBuilder: (ctx, i) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: i == 0 ? ColorTokens.bgElevated : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: i == 0 ? ColorTokens.accentCyan : ColorTokens.bgBorder),
              ),
              child: Text(_locations[i],
                  style: GoogleFonts.ibmPlexSans(
                      color: i == 0 ? ColorTokens.accentCyan : ColorTokens.textSecond, fontSize: 12)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._jobs.asMap().entries.map((e) {
          final j = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TLCard(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(j.company,
                          style: GoogleFonts.syne(color: ColorTokens.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(j.role,
                          style: GoogleFonts.ibmPlexSans(color: ColorTokens.textSecond, fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(children: [
                        TLBadge(j.exp),
                        const SizedBox(width: 6),
                        TLBadge(j.location, color: ColorTokens.accentGreen),
                      ]),
                      const SizedBox(height: 4),
                      Text(j.salary,
                          style: GoogleFonts.jetBrainsMono(color: ColorTokens.accentAmber, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse(j.url), mode: LaunchMode.externalApplication),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorTokens.accentCyan),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Apply →',
                        style: GoogleFonts.ibmPlexSans(color: ColorTokens.accentCyan, fontSize: 12)),
                  ),
                ),
              ]),
            ).animate(delay: (e.key * 50).ms).fadeIn(),
          );
        }),
      ],
    );
  }
}
