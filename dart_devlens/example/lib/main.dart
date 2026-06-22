import 'package:flutter/material.dart';
import 'package:dart_devlens/dart_devlens.dart';

void main() {
  runApp(
    // ─── One line to enable DevLens ──────────────────────────────────────────
    DevLens.wrap(
      config: DevLensConfig(
        showRebuildBadges: true,
        showPerfBar: true,
        showStateLog: true,
        showTapInspector: true,
        rebuildWarningThreshold: 5,
        rebuildDangerThreshold: 15,
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevLens Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF534AB7)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// ── Home page ────────────────────────────────────────────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DevLens Demo'),
        backgroundColor: const Color(0xFF534AB7),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _InfoBanner(),
          const SizedBox(height: 20),

          // ── Tracked widgets — rebuilds show badges ──────────────────────
          DevLens.track(
            name: 'CounterCard',
            child: const CounterCard(),
          ),
          const SizedBox(height: 12),
          DevLens.track(
            name: 'TimerCard',
            child: const TimerCard(),
          ),
          const SizedBox(height: 12),
          DevLens.track(
            name: 'ProductList',
            child: const ProductList(),
          ),
          const SizedBox(height: 24),

          // ── Manual DevLens.logState usage ─────────────────────────────
          const _ManualLogDemo(),
        ],
      ),
    );
  }
}

// ── CounterCard — uses DevLensStateMixin ─────────────────────────────────────

class CounterCard extends StatefulWidget {
  const CounterCard({super.key});

  @override
  State<CounterCard> createState() => _CounterCardState();
}

class _CounterCardState extends State<CounterCard> with DevLensStateMixin {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Counter',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text(
              'Uses DevLensStateMixin — each tap logs a state event',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('$_count',
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () =>
                      setStateTracked(() => _count++, description: '++'),
                  child: const Text('+ Increment'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () =>
                      setStateTracked(() => _count = 0, description: 'reset'),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── TimerCard — rapid setState to show perf bar ──────────────────────────────

class TimerCard extends StatefulWidget {
  const TimerCard({super.key});

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard>
    with TickerProviderStateMixin, DevLensStateMixin {
  late final AnimationController _ticker;
  int _ticks = 0;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _ticker.addListener(() {
      setStateTracked(() => _ticks++, description: 'tick');
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  bool get _running => _ticker.isAnimating;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rapid rebuilder',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text(
              'Runs continuous setState — watch the perf bar and rebuild badge',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Ticks: $_ticks',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    if (_running) {
                      _ticker.stop();
                    } else {
                      _ticker.repeat();
                    }
                    setStateTracked(() {},
                        description: _running ? 'stopped' : 'started');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _running
                        ? const Color(0xFFE24B4A)
                        : const Color(0xFF1D9E75),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_running ? 'Stop' : 'Start'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── ProductList — heavy-ish list to demonstrate tracker ─────────────────────

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> with DevLensStateMixin {
  final _items = [
    'Widget A',
    'Widget B',
    'Widget C',
    'Widget D',
    'Widget E',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Product list',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                TextButton(
                  onPressed: () => setStateTracked(() {
                    _items.shuffle();
                  }, description: 'shuffled'),
                  child: const Text('Shuffle'),
                ),
              ],
            ),
            const Text(
              'Each shuffle triggers a rebuild — watch the badge',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ..._items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      const Icon(Icons.circle,
                          size: 6, color: Color(0xFF534AB7)),
                      const SizedBox(width: 8),
                      Text(item),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Manual log demo ──────────────────────────────────────────────────────────

class _ManualLogDemo extends StatelessWidget {
  const _ManualLogDemo();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF1EFE8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manual DevLens.logState()',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text(
              'Use with providers, blocs, or any non-setState state managers',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => DevLens.logState('UserProvider',
                      description: 'user signed in'),
                  child: const Text('Log sign-in'),
                ),
                ElevatedButton(
                  onPressed: () => DevLens.logState('CartBloc',
                      description: 'item added'),
                  child: const Text('Log cart update'),
                ),
                ElevatedButton(
                  onPressed: () => DevLens.logState('ThemeCubit',
                      description: 'dark mode toggled'),
                  child: const Text('Log theme change'),
                ),
                OutlinedButton(
                  onPressed: DevLens.reset,
                  child: const Text('Reset session'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info banner ──────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDFE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFAFA9EC)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('dart_devlens is active',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3C3489))),
          SizedBox(height: 4),
          Text(
            '• Top-left circle → toggle all overlays\n'
            '• Purple circle (bottom-right) → tap to inspect widgets\n'
            '• Gear icon (bottom-right) → open session report\n'
            '• STATE tab (right edge) → slide out state log',
            style: TextStyle(fontSize: 12, color: Color(0xFF534AB7)),
          ),
        ],
      ),
    );
  }
}
