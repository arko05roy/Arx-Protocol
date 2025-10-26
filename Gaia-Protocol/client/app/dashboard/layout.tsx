"use client"

import type React from "react"
import { TaskProvider } from "@/lib/task-context"
import { SessionNavBar } from "@/components/ui/session-sidebar"

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <TaskProvider>
      <div
        className="h-screen bg-background bg-cover bg-center bg-no-repeat"
        style={{ backgroundImage: "url(/dashboard-bg.jpg)" }}
      >
        <SessionNavBar />
        {/* pad content to avoid overlap with fixed sidebar: ~3rem collapsed, ~15rem expanded */}
        <main className="ml-12 md:ml-60 flex-1 overflow-auto flex flex-col">
          {children}
        </main>
      </div>
    </TaskProvider>
  )
}
