import type { IconType } from "react-icons";
import { LuBookOpen, LuCode, LuListChecks, LuMic } from "react-icons/lu";
import type { Progress } from "@/lib/progress.ts";
import type { TopicStatus } from "@shared/types.ts";

export type Step = {
  id: string;
  label: string;
  detail: string;
  icon: IconType;
  status: Progress;
};

export const QUIZ_PASS = 0.7;

export function topicSteps(st: TopicStatus): Step[] {
  const steps: Step[] = [
    {
      id: "lesson",
      label: "Lesson",
      detail: st.lessonDone ? "Read" : "Read the lesson",
      icon: LuBookOpen,
      status: st.lessonDone ? "done" : "new",
    },
  ];
  if (st.hasQuiz)
    steps.push({
      id: "quiz",
      label: "Quiz",
      detail:
        st.quizBest === null
          ? "Score 70% to pass"
          : `Best ${Math.round(st.quizBest * 100)}%`,
      icon: LuListChecks,
      status:
        st.quizBest === null
          ? "new"
          : st.quizBest >= QUIZ_PASS
            ? "done"
            : "started",
    });
  if (st.required)
    steps.push({
      id: "problems",
      label: "Problems",
      detail: `${st.solved} of ${st.required} solved`,
      icon: LuCode,
      status:
        st.solved === st.required ? "done" : st.solved ? "started" : "new",
    });
  steps.push({
    id: "explain",
    label: "Explain",
    detail: st.explained ? "Submitted" : "Teach it back",
    icon: LuMic,
    status: st.explained ? "done" : "new",
  });
  return steps;
}
