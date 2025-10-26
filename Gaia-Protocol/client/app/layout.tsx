import type React from "react"
import type { Metadata } from "next"
import { Poppins, Roboto, Roboto_Condensed } from "next/font/google"
import { Analytics } from "@vercel/analytics/next"
import "./globals.css"
import FloatingChat from "@/components/floating-chat"
import { headers } from "next/headers";
import { cookieToInitialState } from "wagmi";
import { getConfig } from "./config";
import { Providers } from "./providers";



const poppins = Poppins({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700", "800"],
  variable: "--font-poppins",
})

const roboto = Roboto({
  subsets: ["latin"],
  weight: ["400", "500", "700"],
  variable: "--font-roboto",
})

const robotoCondensed = Roboto_Condensed({
  subsets: ["latin"],
  weight: ["300", "400", "500", "700"],
  style: ["normal", "italic"],
  variable: "--font-roboto-condensed",
})

export const metadata: Metadata = {
  title: "Arx Protocol - Empowering Real-World Impact",
  description: "Arx Protocol connects dreamers and doers — funding real actions that heal the planet.",
  generator: "v0.app",
}

export default async function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>)
{
  const initialState = cookieToInitialState(
    getConfig(),
    (await headers()).get("cookie")
  );
  return (
    <html lang="en">
      <body className={`${poppins.variable} ${roboto.variable} ${robotoCondensed.variable} font-sans antialiased roboto-condensed`}>
        <Providers initialState={initialState}>
          {children}
        <FloatingChat />
        <Analytics />
        </Providers>
      </body>
    </html>
  )
}
