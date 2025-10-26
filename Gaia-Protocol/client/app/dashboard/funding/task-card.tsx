"use client"

import React from "react"
import { motion } from "framer-motion"
import { Leaf, Loader } from "lucide-react"
import { Button } from "@/components/ui/button"
import { formatUnits } from "viem"
import { useGetFundingProgress } from "@/hooks"
import type { Task } from "@/hooks/useTaskRegistry"

interface TaskCardProps {
  task: Task
  index: number
  isLoading: boolean
  onFund: () => void
}

export default function TaskCard({ task, index, isLoading, onFund }: TaskCardProps) {
  const estimatedCost = Number(formatUnits(task.estimatedCost, 18))
  const expectedCO2 = Number(formatUnits(task.expectedCO2, 18))
  
  // Hook call at component level - not in map
  const { funded, target } = useGetFundingProgress(task.id)
  const fundingPercentage = target && target > 0n ? Number((funded * 100n) / target) : 0

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.1 }}
      className="border border-border rounded-lg overflow-hidden bg-card hover:shadow-lg transition-shadow"
    >
      {/* Image */}
      <div className="h-40 bg-gradient-to-br from-primary/20 to-primary/5 overflow-hidden">
        <img src="/mangrove-planting-1.jpg" alt={task.description} className="w-full h-full object-cover" />
      </div>

      {/* Content */}
      <div className="p-4 space-y-4">
        <div>
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-semibold text-primary bg-primary/10 px-2 py-1 rounded">
              Transaction #{Number(task.id)}
            </span>
            <span className="text-xs text-foreground/60">{task.location}</span>
          </div>
          <h3 className="font-semibold text-foreground line-clamp-2">{task.description}</h3>
          <p className="text-sm text-foreground/60 mt-1 line-clamp-2">{task.proofRequirements}</p>
        </div>

        {/* Progress */}
        <div>
          <div className="flex justify-between text-sm mb-2">
            <span className="text-foreground/60">Funding Progress</span>
            <span className="font-semibold text-foreground">
              {funded ? formatUnits(funded, 18) : "0"} / {estimatedCost.toLocaleString()} ARX
            </span>
          </div>
          <div className="w-full h-2 bg-foreground/10 rounded-full overflow-hidden">
            <div
              className="h-full bg-primary transition-all"
              style={{ width: `${Math.min(fundingPercentage, 100)}%` }}
            />
          </div>
        </div>

        {/* Credits */}
        <div className="flex items-center gap-2 text-sm text-foreground/70">
          <Leaf className="h-4 w-4 text-primary" />
          <span>{expectedCO2.toLocaleString()} CO₂ tons expected</span>
        </div>

        {/* Fund Button - Only show if not fully funded */}
        {fundingPercentage < 100 && (
          <Button
            onClick={onFund}
            className="w-full bg-primary hover:bg-primary/90 text-white gap-2"
            disabled={isLoading}
          >
            {isLoading ? (
              <>
                <Loader className="h-4 w-4 animate-spin" />
                Processing...
              </>
            ) : (
              "Fund Now"
            )}
          </Button>
        )}
        
        {/* Fully Funded Badge */}
        {fundingPercentage >= 100 && (
          <div className="w-full py-2 px-4 bg-green-50 border border-green-200 rounded-lg text-center">
            <span className="text-sm font-semibold text-green-700">✓ Fully Funded</span>
          </div>
        )}
      </div>
    </motion.div>
  )
}
