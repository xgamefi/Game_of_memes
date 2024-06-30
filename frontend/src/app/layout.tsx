import '@rainbow-me/rainbowkit/styles.css'
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "GOME token claim",
  description: "Claim GOME token",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
        <html lang="en"
        style={{
          height: `100%`,
          width: `100%`,
          display: `flex`,
          flexDirection: `column`,
          alignItems: `center`,
          justifyContent: `center`,
        }}
        >
          <body className={inter.className}
            style={{
              height: `100%`,
              width: `100%`,
              display: `flex`,
              flexDirection: `column`,
              alignItems: `center`,
              justifyContent: `center`,
            }}
          >{children}</body>
        </html>
  );
}
