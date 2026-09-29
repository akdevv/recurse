import "@/index.css";
import { StrictMode, Suspense, lazy } from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter, Routes, Route } from "react-router";
import RootLayout from "@/components/common/root-layout.tsx";
import SidebarLayout from "@/components/common/sidebar-layout.tsx";
import Home from "@/pages/home.tsx";
import Course from "@/pages/course.tsx";
import TopicPage from "@/pages/topic.tsx";
import Boss from "@/pages/boss.tsx";
import Review from "@/pages/review.tsx";
import Problems from "@/pages/problems.tsx";
import Patterns from "@/pages/patterns.tsx";
import Stats from "@/pages/stats.tsx";
import Rewards from "@/pages/rewards.tsx";
import Settings from "@/pages/settings.tsx";
import NotFound from "@/pages/not-found.tsx";
const ProblemPage = lazy(() => import("@/pages/problem.tsx"));

if ("serviceWorker" in navigator) navigator.serviceWorker.register("/sw.js");

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <BrowserRouter>
      <Routes>
        <Route element={<RootLayout />}>
          <Route element={<SidebarLayout />}>
            <Route index element={<Home />} />
            <Route path="course" element={<Course />} />
            <Route path="course/:moduleId/:topicId" element={<TopicPage />} />
            <Route path="review" element={<Review />} />
            <Route path="problems" element={<Problems />} />
            <Route path="patterns" element={<Patterns />} />
            <Route path="stats" element={<Stats />} />
            <Route path="rewards" element={<Rewards />} />
            <Route path="settings" element={<Settings />} />
            <Route path="*" element={<NotFound />} />
          </Route>
          <Route
            path="problems/:id"
            element={
              <Suspense>
                <ProblemPage />
              </Suspense>
            }
          />
          <Route path="boss/:moduleId" element={<Boss />} />
        </Route>
      </Routes>
    </BrowserRouter>
  </StrictMode>,
);
