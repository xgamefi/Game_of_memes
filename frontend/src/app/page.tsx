"use client"
import Image from "next/image";
import styles from "./page.module.css";
import { getDefaultConfig, RainbowKitProvider } from '@rainbow-me/rainbowkit';
import { base, baseSepolia } from "wagmi/chains"
import { WagmiProvider } from "wagmi";
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import Main from "./main";
import { useState, useEffect } from "react";

const queryClient = new QueryClient()

export const config = getDefaultConfig({
  appName: 'RainbowKit App',
  projectId: 'YOUR_PROJECT_ID',
  chains: 
    (process.env.NEXT_PUBLIC_MAINNET === 'true' ? [base] : [baseSepolia]),
  ssr: true,
});

export default function Home() {
  const [ready, setReady] = useState(false)

  useEffect(() => {
    setReady(true)
  }, [])

  return (
    ready ? <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
      <RainbowKitProvider>
          <Main />
      </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider> : null
  );
}
