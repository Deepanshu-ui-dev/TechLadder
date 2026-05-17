/// Roadmap data model
class RoadmapMeta {
  final String id;
  final String title;
  final String emoji;
  final String category;
  final String weeks;
  final int totalNodes;
  final String description;

  const RoadmapMeta({
    required this.id,
    required this.title,
    required this.emoji,
    required this.category,
    required this.weeks,
    required this.totalNodes,
    required this.description,
  });
}

/// Node completion state
enum NodeState { locked, available, completed }

/// Roadmap node
class RoadmapNode {
  final String id;
  final String title;
  final String emoji;
  final String difficulty;
  final String estimatedTime;
  final String description;
  final List<NodeResource> resources;
  final String? parentId;

  const RoadmapNode({
    required this.id,
    required this.title,
    required this.emoji,
    required this.difficulty,
    required this.estimatedTime,
    required this.description,
    required this.resources,
    this.parentId,
  });
}

class NodeResource {
  final String type; // youtube, github, article
  final String title;
  final String url;

  const NodeResource({
    required this.type,
    required this.title,
    required this.url,
  });
}

// All roadmaps metadata
const List<RoadmapMeta> allRoadmaps = [
  // Placement & Career
  RoadmapMeta(
    id: 'placement-kit',
    title: 'A to Z Placement Kit',
    emoji: '🎯',
    category: 'Placement',
    weeks: '8 weeks',
    totalNodes: 32,
    description: 'End-to-end placement preparation covering aptitude, DSA, HR, and resume.',
  ),
  RoadmapMeta(
    id: 'placement-2026',
    title: 'Placement Roadmap 2026',
    emoji: '🏢',
    category: 'Placement',
    weeks: '12 weeks',
    totalNodes: 40,
    description: 'Structured roadmap for campus placements in 2026 — top IT and product companies.',
  ),
  RoadmapMeta(
    id: 'aptitude',
    title: 'Aptitude & Reasoning',
    emoji: '🧮',
    category: 'Placement',
    weeks: '4 weeks',
    totalNodes: 20,
    description: 'Quantitative aptitude, logical reasoning, and verbal ability for TCS/Infosys/Wipro.',
  ),
  RoadmapMeta(
    id: 'resume-guide',
    title: 'ATS Resume Guide',
    emoji: '📄',
    category: 'Placement',
    weeks: '1 week',
    totalNodes: 8,
    description: 'Build an ATS-friendly resume that gets past screening and lands interviews.',
  ),
  // DSA & Coding
  RoadmapMeta(
    id: 'dsa-2026',
    title: 'DSA Roadmap 2026',
    emoji: '⚡',
    category: 'DSA',
    weeks: '16 weeks',
    totalNodes: 48,
    description: 'Complete Data Structures & Algorithms roadmap from arrays to DP — interview ready.',
  ),
  RoadmapMeta(
    id: 'system-design',
    title: 'System Design (HLD + LLD)',
    emoji: '🏗️',
    category: 'DSA',
    weeks: '8 weeks',
    totalNodes: 28,
    description: 'High-Level and Low-Level system design for senior roles at top product companies.',
  ),
  RoadmapMeta(
    id: 'leetcode-150',
    title: 'LeetCode Top 150',
    emoji: '🔢',
    category: 'DSA',
    weeks: '6 weeks',
    totalNodes: 30,
    description: 'Curated 150 most-asked LeetCode questions organized by pattern.',
  ),
  // Web & Software
  RoadmapMeta(
    id: 'javascript',
    title: 'JavaScript Roadmap',
    emoji: '🟡',
    category: 'Web',
    weeks: '8 weeks',
    totalNodes: 36,
    description: 'From JS basics to advanced concepts — closures, async, ES2024+.',
  ),
  RoadmapMeta(
    id: 'react',
    title: 'React.js Roadmap',
    emoji: '⚛️',
    category: 'Web',
    weeks: '10 weeks',
    totalNodes: 40,
    description: 'React from fundamentals to production — hooks, context, React 19, testing.',
  ),
  RoadmapMeta(
    id: 'backend',
    title: 'Backend (Node.js + REST)',
    emoji: '🖥️',
    category: 'Web',
    weeks: '10 weeks',
    totalNodes: 38,
    description: 'Build production REST APIs with Node.js, Express, PostgreSQL, and Redis.',
  ),
  RoadmapMeta(
    id: 'devops',
    title: 'DevOps 2026',
    emoji: '🚀',
    category: 'Web',
    weeks: '12 weeks',
    totalNodes: 44,
    description: 'DevOps from Linux basics to CI/CD, Docker, Kubernetes, and cloud.',
  ),
  // AI & Emerging
  RoadmapMeta(
    id: 'ai-engineer',
    title: 'AI Engineer Roadmap 2026',
    emoji: '🤖',
    category: 'AI/ML',
    weeks: '16 weeks',
    totalNodes: 52,
    description: 'Become an AI engineer — Python, ML, LLMs, RAG, agents, and deployment.',
  ),
  RoadmapMeta(
    id: 'ml',
    title: 'Machine Learning Roadmap',
    emoji: '🧠',
    category: 'AI/ML',
    weeks: '12 weeks',
    totalNodes: 42,
    description: 'ML from scratch — regression to deep learning and MLOps.',
  ),
  // Projects & Resources
  RoadmapMeta(
    id: 'projects',
    title: 'Final Year Projects',
    emoji: '💡',
    category: 'Projects',
    weeks: '8 weeks',
    totalNodes: 16,
    description: '20+ project ideas with implementation guides for final year students.',
  ),
];

/// DSA roadmap nodes
const List<RoadmapNode> dsaNodes = [
  // Section 1 — Foundations
  RoadmapNode(
    id: 'arrays',
    title: 'Arrays & Strings',
    emoji: '📊',
    difficulty: 'Easy',
    estimatedTime: '~6 hours',
    description: 'Core array operations, string manipulation, subarray problems, and prefix sums.',
    resources: [
      NodeResource(type: 'youtube', title: 'Arrays Playlist — Love Babbar', url: 'https://youtube.com/playlist?list=PL4PCksYQGLJM7OyF8aKEzQdFs-YKOwGz4'),
      NodeResource(type: 'article', title: 'GeeksForGeeks — Arrays', url: 'https://www.geeksforgeeks.org/array-data-structure/'),
    ],
  ),
  RoadmapNode(
    id: 'linked-lists',
    title: 'Linked Lists',
    emoji: '🔗',
    difficulty: 'Easy',
    estimatedTime: '~8 hours',
    description: 'Singly, doubly, and circular linked lists. Reversal, cycle detection, merge.',
    resources: [
      NodeResource(type: 'youtube', title: 'Linked List — Striver', url: 'https://youtube.com/playlist?list=PLgUwDviBIf0p4ozDR_kJJkONnb1wdx2Ma'),
    ],
    parentId: 'arrays',
  ),
  RoadmapNode(
    id: 'stacks-queues',
    title: 'Stacks & Queues',
    emoji: '📚',
    difficulty: 'Easy',
    estimatedTime: '~6 hours',
    description: 'Stack/queue implementation, monotonic stack, circular queue, deque.',
    resources: [
      NodeResource(type: 'youtube', title: 'Stacks & Queues — Apna College', url: 'https://youtube.com/playlist?list=PLfqMkBi-ZHnwq9R5CDdoIkTLPMrJTHBzU'),
    ],
    parentId: 'linked-lists',
  ),
  RoadmapNode(
    id: 'hashing',
    title: 'Hashing & Maps',
    emoji: '🗂️',
    difficulty: 'Easy',
    estimatedTime: '~5 hours',
    description: 'HashMap, HashSet, frequency counting, two-sum pattern.',
    resources: [
      NodeResource(type: 'article', title: 'Hashing — GFG', url: 'https://www.geeksforgeeks.org/hashing-data-structure/'),
    ],
    parentId: 'arrays',
  ),
  RoadmapNode(
    id: 'recursion',
    title: 'Recursion',
    emoji: '🔄',
    difficulty: 'Medium',
    estimatedTime: '~8 hours',
    description: 'Recursion fundamentals, call stack visualization, backtracking preview.',
    resources: [
      NodeResource(type: 'youtube', title: 'Recursion — Abdul Bari', url: 'https://youtube.com/playlist?list=PLDN4rrl48XKpZkf03iYFl-O29szjTrs_O'),
    ],
    parentId: 'stacks-queues',
  ),
  RoadmapNode(
    id: 'sorting',
    title: 'Sorting Algorithms',
    emoji: '↕️',
    difficulty: 'Easy',
    estimatedTime: '~6 hours',
    description: 'Bubble, selection, insertion, merge sort, quick sort, heap sort. Time complexity.',
    resources: [
      NodeResource(type: 'youtube', title: 'Sorting — Abdul Bari', url: 'https://youtube.com/watch?v=pkkFqlG0Dqc'),
    ],
    parentId: 'arrays',
  ),
  RoadmapNode(
    id: 'searching',
    title: 'Searching',
    emoji: '🔍',
    difficulty: 'Easy',
    estimatedTime: '~4 hours',
    description: 'Binary search and its variants — first/last occurrence, rotated array.',
    resources: [
      NodeResource(type: 'youtube', title: 'Binary Search — Striver', url: 'https://youtube.com/playlist?list=PLgUwDviBIf0pMFMWuuvDNF12sIoYd8mBP'),
    ],
    parentId: 'sorting',
  ),
  // Section 2 — Intermediate
  RoadmapNode(
    id: 'trees',
    title: 'Trees (BST, AVL)',
    emoji: '🌳',
    difficulty: 'Medium',
    estimatedTime: '~12 hours',
    description: 'Binary trees, BST operations, tree traversals, AVL rotations.',
    resources: [
      NodeResource(type: 'youtube', title: 'Trees — Striver', url: 'https://youtube.com/playlist?list=PLgUwDviBIf0q8Hkd7bK2Bpryj2xVJk8Vk'),
    ],
    parentId: 'recursion',
  ),
  RoadmapNode(
    id: 'heaps',
    title: 'Heaps & Priority Queue',
    emoji: '⛰️',
    difficulty: 'Medium',
    estimatedTime: '~6 hours',
    description: 'Min/max heap, heapify, K-th largest, priority queue patterns.',
    resources: [
      NodeResource(type: 'article', title: 'Heaps — GFG', url: 'https://www.geeksforgeeks.org/heap-data-structure/'),
    ],
    parentId: 'trees',
  ),
  RoadmapNode(
    id: 'tries',
    title: 'Tries',
    emoji: '🔤',
    difficulty: 'Medium',
    estimatedTime: '~5 hours',
    description: 'Trie insert/search, word search, prefix matching, XOR problems.',
    resources: [
      NodeResource(type: 'youtube', title: 'Tries — Striver', url: 'https://youtube.com/watch?v=dBGUmUQhjaM'),
    ],
    parentId: 'hashing',
  ),
  RoadmapNode(
    id: 'graphs',
    title: 'Graphs (BFS/DFS)',
    emoji: '🕸️',
    difficulty: 'Medium',
    estimatedTime: '~14 hours',
    description: 'Graph representation, BFS, DFS, topological sort, shortest path.',
    resources: [
      NodeResource(type: 'youtube', title: 'Graphs — Striver', url: 'https://youtube.com/playlist?list=PLgUwDviBIf0oE3gA41TKO2H5bHpPd7fzn'),
    ],
    parentId: 'trees',
  ),
  RoadmapNode(
    id: 'union-find',
    title: 'Union Find',
    emoji: '🔀',
    difficulty: 'Medium',
    estimatedTime: '~4 hours',
    description: 'Disjoint Set Union, path compression, union by rank, Kruskal\'s MST.',
    resources: [
      NodeResource(type: 'article', title: 'DSU — CP-Algorithms', url: 'https://cp-algorithms.com/data_structures/disjoint_set_union.html'),
    ],
    parentId: 'graphs',
  ),
  RoadmapNode(
    id: 'segment-trees',
    title: 'Segment Trees',
    emoji: '🌲',
    difficulty: 'Hard',
    estimatedTime: '~8 hours',
    description: 'Range queries, lazy propagation, merge sort tree.',
    resources: [
      NodeResource(type: 'article', title: 'Segment Tree — GFG', url: 'https://www.geeksforgeeks.org/segment-tree-set-1-sum-of-given-range/'),
    ],
    parentId: 'trees',
  ),
  // Section 3 — Advanced
  RoadmapNode(
    id: 'dp',
    title: 'Dynamic Programming',
    emoji: '💡',
    difficulty: 'Hard',
    estimatedTime: '~20 hours',
    description: 'Memoization, tabulation, knapsack, LCS, LIS, MCM, DP on trees/graphs.',
    resources: [
      NodeResource(type: 'youtube', title: 'DP Series — Striver', url: 'https://youtube.com/playlist?list=PLgUwDviBIf0qUlt5H_kiKYaNSqJ81PMMY'),
    ],
    parentId: 'recursion',
  ),
  RoadmapNode(
    id: 'greedy',
    title: 'Greedy Algorithms',
    emoji: '💰',
    difficulty: 'Medium',
    estimatedTime: '~6 hours',
    description: 'Activity selection, Huffman coding, job scheduling, interval problems.',
    resources: [
      NodeResource(type: 'article', title: 'Greedy — GFG', url: 'https://www.geeksforgeeks.org/greedy-algorithms/'),
    ],
    parentId: 'dp',
  ),
  RoadmapNode(
    id: 'backtracking',
    title: 'Backtracking',
    emoji: '↩️',
    difficulty: 'Hard',
    estimatedTime: '~8 hours',
    description: 'N-Queens, Sudoku, permutations, subsets, word search.',
    resources: [
      NodeResource(type: 'youtube', title: 'Backtracking — Striver', url: 'https://youtube.com/playlist?list=PLgUwDviBIf0p4ozDR_kJJkONnb1wdx2Ma'),
    ],
    parentId: 'recursion',
  ),
  RoadmapNode(
    id: 'bit-manipulation',
    title: 'Bit Manipulation',
    emoji: '🔣',
    difficulty: 'Medium',
    estimatedTime: '~5 hours',
    description: 'Bit tricks, XOR problems, power of two checks, subsets with bits.',
    resources: [
      NodeResource(type: 'article', title: 'Bit Manipulation — GFG', url: 'https://www.geeksforgeeks.org/bit-manipulation-1/'),
    ],
    parentId: 'hashing',
  ),
  // Section 4 — Interview Patterns
  RoadmapNode(
    id: 'two-pointers',
    title: 'Two Pointers',
    emoji: '👆',
    difficulty: 'Medium',
    estimatedTime: '~5 hours',
    description: 'Two-pointer technique for sorted arrays, pair sum, triplet sum.',
    resources: [
      NodeResource(type: 'youtube', title: 'Two Pointers — NeetCode', url: 'https://youtube.com/watch?v=On03HWe2tZM'),
    ],
    parentId: 'arrays',
  ),
  RoadmapNode(
    id: 'sliding-window',
    title: 'Sliding Window',
    emoji: '🪟',
    difficulty: 'Medium',
    estimatedTime: '~6 hours',
    description: 'Fixed and variable window, max subarray, substring problems.',
    resources: [
      NodeResource(type: 'youtube', title: 'Sliding Window — NeetCode', url: 'https://youtube.com/watch?v=GcW4mgmgSbw'),
    ],
    parentId: 'arrays',
  ),
  RoadmapNode(
    id: 'monotonic-stack',
    title: 'Monotonic Stack',
    emoji: '📈',
    difficulty: 'Medium',
    estimatedTime: '~5 hours',
    description: 'Next greater/smaller element, histogram, trapping rainwater.',
    resources: [
      NodeResource(type: 'youtube', title: 'Monotonic Stack — NeetCode', url: 'https://youtube.com/watch?v=Dq_6DxP7MJ8'),
    ],
    parentId: 'stacks-queues',
  ),
  RoadmapNode(
    id: 'dp-patterns',
    title: 'DP Patterns',
    emoji: '🗂️',
    difficulty: 'Hard',
    estimatedTime: '~10 hours',
    description: 'Common DP patterns: 1D, 2D, partitioning, intervals, bitmask DP.',
    resources: [
      NodeResource(type: 'youtube', title: 'DP Patterns — Striver', url: 'https://youtube.com/playlist?list=PLgUwDviBIf0qUlt5H_kiKYaNSqJ81PMMY'),
    ],
    parentId: 'dp',
  ),
];
