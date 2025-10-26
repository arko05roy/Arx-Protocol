"use client"

import { useSidebar } from "@/lib/sidebar-context"
import { motion } from "framer-motion"
import { ReactNode } from "react"

interface ResponsiveHeadingProps {
  children: ReactNode
  className?: string
}

export function ResponsiveHeading({ children, className = "" }: ResponsiveHeadingProps) {
  const { isCollapsed } = useSidebar()

  return (
    <motion.div
      className={className}
      animate={{
        marginLeft: isCollapsed ? "0px" : "0px",
      }}
      transition={{
        type: "tween",
        ease: "easeOut",
        duration: 0.2,
      }}
    >
      {children}
    </motion.div>
  )
}
