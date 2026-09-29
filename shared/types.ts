export type Difficulty = "Easy" | "Medium" | "Hard";
export type Role = "guided" | "core" | "optional";
export type Outcome = "solved" | "hinted" | "assisted";
export type ProblemStatus = "new" | "in-progress" | Outcome;

export type Course = {
  id: string;
  title: string;
  language: string;
  modules: string[];
};
export type Module = {
  id: string;
  number: number;
  title: string;
  summary: string;
  prereqs: string[];
  topics: string[];
  boss: { timeLimitMin: number };
};
// title/difficulty/lc are only set for problems not imported yet (stub topics)
export type ProblemRef = {
  id: string;
  role: Role;
  note?: string;
  title?: string;
  difficulty?: Difficulty;
  lc?: number;
};
export type Topic = {
  id: string;
  title: string;
  status: "ready" | "stub";
  learn: string;
  hook?: string;
  patterns: string[];
  problems: ProblemRef[];
  explain: { prompt: string; keyPoints: string[] };
};
export type QuizQ = {
  id: string;
  kind: string;
  q: string;
  code?: string;
  options: string[];
  answer: number;
  why: string;
};
export type SolutionMeta = {
  id: string;
  title: string;
  time: string;
  space: string;
  reference?: boolean;
  slow?: boolean;
};
export type Problem = {
  id: string;
  lc: { id: number; slug: string } | null;
  title: string;
  difficulty: Difficulty;
  patterns: string[];
  starter: string;
  entry: {
    method: string;
    params: { name: string; type: string }[];
    returns: string;
    outputParam?: number;
    design?: boolean; // method = class name; params = LeetCode's [ops, args] lines
  };
  examples: string[];
  judge: { compare: string; timeLimitMs: number };
  solutions: SolutionMeta[];
  hints: string[];
  lcHints: string[];
  explain: { keyPoints: string[] };
};

export type VizTrace = {
  title: string;
  view: "array" | "stack" | "tree" | "grid" | "list" | "graph";
  steps: Record<string, any>[];
};

export type TopicStatus = {
  lessonDone: boolean;
  quizBest: number | null;
  hasQuiz: boolean;
  explained: boolean;
  solved: number;
  required: number;
  complete: boolean;
};
export type ModuleView = Module & {
  unlocked: boolean;
  complete: boolean;
  topicViews: TopicView[];
};
export type TopicProblem = {
  id: string;
  title: string;
  role: Role;
  difficulty: Difficulty | null;
  lc: number | null;
  available: boolean;
  status: ProblemStatus;
};
export type TopicView = Pick<Topic, "id" | "title" | "status"> &
  TopicStatus & { problems: TopicProblem[] };
export type Me = {
  username: string;
  xp: number;
  level: { level: number; into: number; need: number; title: string };
  today: { seconds: number; goal: number; done: boolean };
  weekStreak: number;
  dayStreak: number;
  freezes: number;
  thisWeek: { date: string; seconds: number; qualifies: boolean }[];
  reviewsDue: number;
  chests: number; // unopened mystery chests
};
export type NextAction = {
  kind: "review" | "learn" | "solve" | "finish" | "browse";
  title: string;
  context: string;
  href: string;
};
export type ProblemView = {
  problem: Omit<Problem, "solutions" | "hints" | "lcHints">;
  statement: string;
  home: {
    moduleId: string;
    topicId: string;
    topicTitle: string;
    role: Role;
  } | null;
  status: ProblemStatus;
  attempt: {
    id: number;
    activeSeconds: number;
    hintsUsed: number;
    solutionViewed: boolean;
    code: string;
    finished: boolean;
    outcome: Outcome | null;
    explain: string;
  } | null;
  unlocks: {
    hintsAvailable: number;
    nextHintAt: number | null;
    solutionAvailable: boolean;
    solutionAt: number;
  };
  hintCount: number;
  hints: string[];
  solutionCount: number;
  solutions: (SolutionMeta & { code: string; md: string })[] | null;
  explainKeyPoints: string[] | null;
  tutor: {
    unlocked: boolean; // after hint 1, never in a boss fight
    open: boolean;
    messages: TutorMessage[];
  };
  boss: { runId: number; moduleId: string; deadline: string } | null;
  submissions: {
    id: number;
    ts: string;
    kind: string;
    verdict: string;
    passed: number;
    total: number;
  }[];
};
export type TutorMessage = { role: "user" | "tutor"; text: string };

export type Grade = {
  score: number; // 0..5
  covered: boolean[]; // one per key point
  feedback: string;
  followUp: string;
};

export type ChestSource = "boss" | "solve";
export type ChestReward =
  | { kind: "xp"; amount: number }
  | { kind: "freeze" }
  | { kind: "collectible"; id: string; name: string; desc: string };
export type EarnedChest = { id: number; source: ChestSource };
export type Chests = {
  unopened: { id: number; ts: string; source: ChestSource }[];
  opened: {
    id: number;
    openedAt: string;
    source: ChestSource;
    reward: ChestReward;
  }[];
  collectibles: { id: string; name: string; desc: string; owned: boolean }[];
};

export type TopicWrapped = {
  seconds: number; // active time on the topic's problems
  solved: number;
  optional: number; // optional problems solved
  total: number;
  hintFree: number; // 0..1 of solved problems
  quizBest: number | null;
  bestExplain: number | null; // topic explain-back, 0..5
  bestProblemExplain: number | null;
  masteredAt: string | null;
};

export type JudgeResult = {
  verdict: string;
  passed: number;
  total: number;
  error?: string;
  slowestMs?: number;
  results: {
    i: number;
    kind: string;
    verdict: string;
    ms: number;
    stdout: string;
    input: string[];
    expected: string | null;
    got: string | null;
    error: string | null;
  }[];
};

export type Settings = {
  username: string;
  plannedDays: number[]; // 0 = Monday
  window: { start: string; end: string }; // reminder window, "HH:MM"
  reminders: boolean;
};
