import './globals.css';
import Protection from './components/Protection';

export const metadata = {
  title: 'FreeForm Helper - AI Humanizer',
  description: 'Bypass Turnitin instantly.',
}

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className="antialiased select-none">
        <Protection />
        {children}
      </body>
    </html>
  )
}
