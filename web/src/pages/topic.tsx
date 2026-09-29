import type { ReactNode } from "react";
import type { IconType } from "react-icons";
import { Link, useParams } from "react-router";
import {
  LuArrowRight,
  LuBookOpen,
  LuCode,
  LuListChecks,
  LuCircleCheck,
  LuLightbulb,
} from "react-icons/lu";
import { post, useApi, emitRefresh } from "@/lib/api.ts";
import { useBreadcrumbs } from "@/lib/breadcrumbs.ts";
import { slugify } from "@/lib/text.ts";
import { topicSteps } from "@/lib/topic-steps.ts";
import type { Progress } from "@/lib/progress.ts";
import Markdown from "@/components/markdown.tsx";
import Button from "@/components/common/button.tsx";
import TopicSteps from "@/components/topic/topic-steps.tsx";
import OnThisPage, { type TocItem } from "@/components/topic/on-this-page.tsx";
import Quiz from "@/components/topic/quiz.tsx";
import ProblemList, {
  type TopicProblemRow,
} from "@/components/topic/problem-list.tsx";
import ExplainCard from "@/components/topic/explain-card.tsx";
import WrappedCard from "@/components/topic/wrapped-card.tsx";
import type {
  QuizQ,
  Topic,
  TopicStatus,
  TopicWrapped,
  VizTrace,
} from "@shared/types.ts";

type TopicData = {
  topic: Topic;
  module: {
    id: string;
    title: string;
    number: number;
    topicIndex: number;
    topicCount: number;
  };
  content: {
    lesson: string;
    quiz: QuizQ[];
    viz: Record<string, VizTrace>;
  } | null;
  status: TopicStatus;
  wrapped: TopicWrapped | null;
  explain: string;
  problems: TopicProblemRow[];
};

export default function TopicPage() {
  const { topicId } = useParams();
  const [d, reload] = useApi<TopicData>(`/topics/${topicId}`);
  useBreadcrumbs(
    d && [
      { label: "Course", to: "/course" },
      { label: d.module.title, to: `/course#${d.module.id}` },
      { label: d.topic.title },
    ],
  );
  if (!d) return null;

  const { topic: t, status: st, content, module: m } = d;
  const steps = topicSteps(st);
  const step = (id: string) => {
    const i = steps.findIndex((s) => s.id === id);
    return { n: i + 1, status: steps[i]?.status ?? ("new" as Progress) };
  };
  const lessonHeadings = content
    ? [...content.lesson.matchAll(/^## (.+)$/gm)].map((x) => x[1].trim())
    : [];
  const toc: TocItem[] = [
    { id: "lesson", label: "Lesson" },
    ...lessonHeadings.map((h) => ({ id: slugify(h), label: h, sub: true })),
    ...(content?.quiz.length ? [{ id: "quiz", label: "Quiz" }] : []),
    ...(d.problems.length ? [{ id: "problems", label: "Problems" }] : []),
    { id: "explain", label: "Explain it back" },
  ];

  const markRead = () =>
    post(`/topics/${t.id}/lesson-done`).then(() => {
      reload();
      emitRefresh();
    });

  return (
    <div className="mx-auto flex w-full max-w-6xl justify-center gap-14 px-8 py-10">
      <article className="flex w-full max-w-3xl min-w-0 flex-col gap-16">
        <header className="flex flex-col gap-7">
          <div>
            <div className="flex items-center gap-2 text-sm text-muted-foreground">
              <Link
                to={`/course#${m.id}`}
                className="transition-colors hover:text-foreground"
              >
                Module {m.number} · {m.title}
              </Link>
              <span className="text-muted-foreground/40">/</span>
              <span className="tabular-nums">
                Topic {m.topicIndex + 1} of {m.topicCount}
              </span>
            </div>
            <h1 className="mt-2 text-3xl font-semibold tracking-tight text-balance">
              {t.title}
            </h1>
            <div className="mt-4 flex flex-wrap items-center gap-x-5 gap-y-2 text-sm text-muted-foreground">
              {lessonHeadings.length > 0 && (
                <Meta icon={LuBookOpen}>{lessonHeadings.length} sections</Meta>
              )}
              {!!content?.quiz.length && (
                <Meta icon={LuListChecks}>
                  {content.quiz.length} quiz questions
                </Meta>
              )}
              {d.problems.length > 0 && (
                <Meta icon={LuCode}>{d.problems.length} problems</Meta>
              )}
            </div>
          </div>

          {d.wrapped ? (
            <WrappedCard title={t.title} w={d.wrapped} />
          ) : (
            <TopicSteps steps={steps} />
          )}

          {t.hook && (
            <p className="flex gap-3 rounded-xl bg-warning/5 px-4 py-3.5 text-sm leading-6 text-foreground/80 ring-1 ring-warning/15 ring-inset">
              <LuLightbulb className="mt-1 size-4 shrink-0 text-warning" />
              <span>
                <span className="font-medium text-warning">
                  Why this matters.{" "}
                </span>
                {t.hook}
              </span>
            </p>
          )}
        </header>

        <Section id="lesson" title="Lesson" {...step("lesson")}>
          {content ? (
            <>
              <Markdown text={content.lesson} viz={content.viz} />
              <div
                className={`mt-6 flex items-center gap-4 rounded-xl px-5 py-4 ring-1 ring-inset ${
                  st.lessonDone
                    ? "bg-success/5 ring-success/20"
                    : "bg-primary/5 ring-primary/20"
                }`}
              >
                <span
                  className={`grid size-9 shrink-0 place-items-center rounded-full ${
                    st.lessonDone
                      ? "bg-success/15 text-success"
                      : "bg-primary/15 text-primary"
                  }`}
                >
                  {st.lessonDone ? (
                    <LuCircleCheck className="size-4.5" />
                  ) : (
                    <LuBookOpen className="size-4" />
                  )}
                </span>
                <div className="min-w-0 flex-1">
                  <div className="text-sm font-medium">
                    {st.lessonDone ? "Lesson complete" : "Finished the lesson?"}
                  </div>
                  <div className="text-xs text-muted-foreground">
                    {st.lessonDone
                      ? "Step 1 is done. Test what stuck with the quiz."
                      : "Mark it as read to complete step 1."}
                  </div>
                </div>
                {st.lessonDone ? (
                  content.quiz.length > 0 && (
                    <a
                      href="#quiz"
                      className="flex h-9 shrink-0 items-center gap-1.5 rounded-md border border-border bg-card px-3.5 text-sm font-medium transition-colors hover:bg-accent"
                    >
                      Go to quiz
                      <LuArrowRight className="size-3.5" />
                    </a>
                  )
                ) : (
                  <Button onClick={markRead}>
                    <LuCircleCheck className="size-4" />
                    Mark as read
                  </Button>
                )}
              </div>
            </>
          ) : (
            <div className="flex items-center gap-3 rounded-xl border border-dashed border-border px-5 py-6 text-sm text-muted-foreground">
              <LuBookOpen className="size-4 shrink-0" />
              The lesson for this topic hasn't been written yet. Its problems
              are listed below.
            </div>
          )}
        </Section>

        {!!content?.quiz.length && (
          <Section
            id="quiz"
            title="Quiz"
            description={`${content.quiz.length} quick questions. Score 70% or more to pass. Retakes only earn XP for beating your best.`}
            {...step("quiz")}
          >
            <Quiz
              key={t.id}
              topicId={t.id}
              quiz={content.quiz}
              best={st.quizBest}
              onDone={reload}
            />
          </Section>
        )}

        {d.problems.length > 0 && (
          <Section
            id="problems"
            title="Problems"
            description="Start with the guided one. Optional problems are extra practice for bonus XP."
            {...step("problems")}
          >
            <ProblemList problems={d.problems} />
          </Section>
        )}

        <Section
          id="explain"
          title="Explain it back"
          description="The interview skill: explain the idea clearly, without notes."
          {...step("explain")}
        >
          <ExplainCard
            key={`${t.id}:${d.explain}`}
            topic={t}
            saved={d.explain}
            onSaved={reload}
          />
        </Section>
      </article>

      <aside className="hidden w-52 shrink-0 xl:block">
        <OnThisPage items={toc} steps={steps} />
      </aside>
    </div>
  );
}

function Section({
  id,
  n,
  status,
  title,
  description,
  children,
}: {
  id: string;
  n: number;
  status: Progress;
  title: string;
  description?: string;
  children: ReactNode;
}) {
  return (
    <section id={id} className="flex scroll-mt-6 flex-col gap-6">
      <div>
        <div className="flex items-center gap-3">
          <span
            className={`grid size-7 shrink-0 place-items-center rounded-full font-mono text-xs font-semibold ring-1 ring-inset ${
              status === "done"
                ? "bg-success/10 text-success ring-success/25"
                : status === "started"
                  ? "bg-primary/10 text-primary ring-primary/25"
                  : "bg-card text-muted-foreground ring-border"
            }`}
          >
            {status === "done" ? <LuCircleCheck className="size-3.5" /> : n}
          </span>
          <h2 className="text-xl font-semibold tracking-tight">{title}</h2>
          <span aria-hidden className="h-px flex-1 bg-border" />
        </div>
        {description && (
          <p className="mt-2 pl-10 text-sm leading-6 text-muted-foreground">
            {description}
          </p>
        )}
      </div>
      {children}
    </section>
  );
}

function Meta({
  icon: Icon,
  children,
}: {
  icon: IconType;
  children: ReactNode;
}) {
  return (
    <span className="flex items-center gap-1.5">
      <Icon className="size-4" />
      {children}
    </span>
  );
}
