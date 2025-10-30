'use client';

import React, { useState, useEffect } from 'react';
import { getUniversalLink } from "@selfxyz/core";
import {
  SelfQRcodeWrapper,
  SelfAppBuilder,
  type SelfApp,
} from "@selfxyz/qrcode";
import { ethers } from "ethers";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Loader, CheckCircle, AlertCircle, X } from "lucide-react";
import { motion } from "framer-motion";

interface SelfVerificationProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
  userAddress?: string;
  onSkip?: () => void;
}

export function SelfVerification({
  isOpen,
  onClose,
  onSuccess,
  userAddress = ethers.ZeroAddress,
  onSkip,
}: SelfVerificationProps) {
  const [selfApp, setSelfApp] = useState<SelfApp | null>(null);
  const [universalLink, setUniversalLink] = useState("");
  const [verificationStatus, setVerificationStatus] = useState<'idle' | 'scanning' | 'verified' | 'error' | 'skipped'>('idle');
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!isOpen) return;

    try {
      setError(null);
      setVerificationStatus('idle');
      
      const app = new SelfAppBuilder({
        version: 2,
        appName: process.env.NEXT_PUBLIC_SELF_APP_NAME || "Arx Protocol",
        scope: process.env.NEXT_PUBLIC_SELF_SCOPE || "arx-protocol",
        endpoint: process.env.NEXT_PUBLIC_SELF_ENDPOINT || "0x16ECBA51e18a4a7e61fdC417f0d47AFEeDfbed74",
        logoBase64: "https://i.postimg.cc/mrmVf9hm/self.png",
        userId: userAddress,
        endpointType: "staging_celo",
        userIdType: "hex",
        userDefinedData: `Operator Verification - ${new Date().toISOString()}`,
        disclosures: {
          minimumAge: 18,
          nationality: true,
          gender: true,
        }
      }).build();

      setSelfApp(app);
      setUniversalLink(getUniversalLink(app));
    } catch (err) {
      console.error("Failed to initialize Self app:", err);
      setError(err instanceof Error ? err.message : "Failed to initialize verification");
      setVerificationStatus('error');
    }
  }, [isOpen, userAddress]);

  const handleSuccessfulVerification = () => {
    setVerificationStatus('verified');
    // Immediately proceed and close modal on success
    try { onSuccess(); } finally { onClose(); }
  };

  const handleError = (err: any) => {
    // Proceed without marking verified if caller allows skipping
    if (onSkip) {
      try { onSkip(); } finally { onClose(); }
      return;
    }
    // Fallback: keep modal with error state and allow manual proceed
    setVerificationStatus('error');
    setError("Verification encountered an issue, but you can still proceed.");
  };

  const handleProceedAnyway = () => {
    // Close modal and allow staking regardless of verification status
    if (onSkip) onSkip();
    onClose();
  };

  if (!isOpen) return null;

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
      onClick={onClose}
    >
      <motion.div
        initial={{ scale: 0.95, y: 20 }}
        animate={{ scale: 1, y: 0 }}
        exit={{ scale: 0.95, y: 20 }}
        onClick={(e) => e.stopPropagation()}
        className="bg-card border border-border rounded-lg shadow-xl max-w-md w-full p-6 space-y-6"
      >
        <div className="flex items-center justify-between">
          <h2 className="text-2xl font-bold">Identity Verification</h2>
          <button
            onClick={onClose}
            className="text-foreground/60 hover:text-foreground"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <div className="space-y-4">
          <p className="text-sm text-foreground/60">
            Before staking, please verify your identity using the Self protocol. Scan the QR code with the Self app on your mobile device.
          </p>

          {/* QR Code Display */}
          {selfApp && verificationStatus !== 'verified' && (
            <div className="flex justify-center p-4 bg-primary/5 rounded-lg border border-primary/20">
              {verificationStatus === 'error' ? (
                <div className="text-center">
                  <AlertCircle className="h-12 w-12 text-red-500 mx-auto mb-2" />
                  <p className="text-sm text-red-600">{error || "Verification failed"}</p>
                </div>
              ) : (
                <SelfQRcodeWrapper
                  selfApp={selfApp}
                  onSuccess={handleSuccessfulVerification}
                  onError={handleError}
                />
              )}
            </div>
          )}

          {/* Verification Success State */}
          {verificationStatus === 'verified' && (
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              className="flex flex-col items-center justify-center p-8 bg-green-50 rounded-lg border border-green-200"
            >
              <CheckCircle className="h-16 w-16 text-green-600 mb-3" />
              <p className="text-lg font-semibold text-green-900">Verified!</p>
              <p className="text-sm text-green-700 text-center mt-1">
                Your identity has been verified successfully.
              </p>
            </motion.div>
          )}

          {/* Status Indicator */}
          {verificationStatus === 'scanning' && (
            <div className="flex items-center justify-center gap-2 p-3 bg-blue-50 rounded-lg border border-blue-200">
              <Loader className="h-4 w-4 animate-spin text-blue-600" />
              <p className="text-sm text-blue-700">Verifying your identity...</p>
            </div>
          )}

          {error && verificationStatus === 'error' && (
            <div className="p-3 rounded-lg bg-red-50 border border-red-200 text-red-700 text-sm flex gap-2">
              <AlertCircle className="h-4 w-4 flex-shrink-0 mt-0.5" />
              <span>{error}</span>
            </div>
          )}
        </div>

        {/* Action Buttons */}
        <div className="flex gap-3">
          <Button
            onClick={onClose}
            variant="outline"
            className="flex-1"
            disabled={false}
          >
            Cancel
          </Button>
          {verificationStatus === 'verified' && (
            <Button
              onClick={handleProceedAnyway}
              className="flex-1 bg-primary text-primary-foreground hover:bg-primary/90"
              disabled={false}
            >
              Proceed
            </Button>
          )}
          {verificationStatus === 'error' && (
            <Button
              onClick={handleProceedAnyway}
              className="flex-1 bg-amber-600 text-white hover:bg-amber-700"
            >
              Proceed Anyway
            </Button>
          )}
        </div>
      </motion.div>
    </motion.div>
  );
}
