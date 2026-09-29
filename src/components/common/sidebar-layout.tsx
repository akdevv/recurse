import { useEffect, useRef } from "react";
import { Outlet, useLocation } from "react-router";
import Sidebar from "@/components/common/sidebar.tsx";
import PageHeader from "@/components/common/page-header.tsx";

export default function SidebarLayout() {
  const scroller = useRef<HTMLDivElement>(null);
  const { pathname } = useLocation();

  // the content pane keeps its scroll position across routes, so start each page at the top
  useEffect(() => {
    scroller.current?.scrollTo(0, 0);
  }, [pathname]);

  return (
    <div className="flex h-screen overflow-hidden">
      <Sidebar />
      <main className="flex min-w-0 flex-1 flex-col">
        <PageHeader />
        <div
          ref={scroller}
          id="content"
          className="flex min-h-0 flex-1 flex-col overflow-y-auto"
        >
          <Outlet />
        </div>
      </main>
    </div>
  );
}
