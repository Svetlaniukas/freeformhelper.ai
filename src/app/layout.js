import './globals.css'
import Protection from './components/Protection';
import SocialProof from './components/SocialProof';
import { GoogleAnalytics } from '@next/third-parties/google';

export const metadata = {
  title: 'Ghostwriter AI - Turn ChatGPT into Human Text',
  description: 'The #1 AI Humanizer used by 50,000+ students. Bypass Turnitin, GPTZero & Originality.ai instantly.',
  verification: { google: 'YOUR_GOOGLE_CONSOLE_CODE' },
}

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className="antialiased select-none">
        <Protection />
        <SocialProof />
        {children}
        {/* <GoogleAnalytics gaId="G-XYZ" /> */}
      </body>
    </html>
  )
}
