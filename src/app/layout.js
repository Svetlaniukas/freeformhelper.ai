import './globals.css';

const SITE = 'https://freeformhelper.ai';

export const metadata = {
  metadataBase: new URL(SITE),
  title: {
    default: 'FreeFormHelper.ai — AI Text Humanizer | Bypass Turnitin, GPTZero & Originality.AI',
    template: '%s | FreeFormHelper.ai',
  },
  description: 'Make AI-generated text 100% undetectable. Bypass Turnitin, GPTZero, and Originality.AI instantly. Free trial — no credit card required.',
  keywords: [
    'AI humanizer', 'bypass Turnitin', 'bypass GPTZero', 'undetectable AI',
    'AI detection remover', 'humanize ChatGPT text', 'essay humanizer',
    'AI text rewriter', 'bypass Originality AI', 'make AI text human',
    'Turnitin bypass 2026', 'AI paraphraser undetectable',
  ],
  authors: [{ name: 'FreeFormHelper.ai' }],
  creator: 'FreeFormHelper.ai',
  robots: { index: true, follow: true, 'max-snippet': -1, 'max-image-preview': 'large' },
  alternates: { canonical: SITE },
  openGraph: {
    type: 'website',
    siteName: 'FreeFormHelper.ai',
    title: 'FreeFormHelper.ai — Make AI Text Undetectable',
    description: 'Bypass Turnitin, GPTZero & Originality.AI. Instant AI text humanization. Free trial.',
    url: SITE,
    locale: 'en_US',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'FreeFormHelper.ai — AI Text Humanizer',
    description: 'Bypass AI detectors instantly. Free trial.',
  },
  other: {
    'application/ld+json': JSON.stringify([
      {
        '@context': 'https://schema.org',
        '@type': 'SoftwareApplication',
        name: 'FreeFormHelper.ai',
        applicationCategory: 'UtilitiesApplication',
        operatingSystem: 'Web',
        description: 'AI text humanizer that rewrites AI-generated content to bypass academic and professional AI detection systems including Turnitin, GPTZero, and Originality.AI.',
        url: SITE,
        offers: [
          { '@type': 'Offer', price: '0', priceCurrency: 'EUR', name: 'Free', description: '300 words/day' },
          { '@type': 'Offer', price: '9.99', priceCurrency: 'EUR', name: 'Pro', billingIncrement: 'P1M', description: '20,000 words/month' },
          { '@type': 'Offer', price: '24.99', priceCurrency: 'EUR', name: 'Premium', billingIncrement: 'P1M', description: 'Unlimited words' },
        ],
        featureList: 'Bypass Turnitin, Bypass GPTZero, Bypass Originality.AI, PDF Upload, DOCX Upload, Multi-language Support, Chrome Extension',
        author: {
          '@type': 'Organization',
          name: 'FreeFormHelper.ai',
          url: SITE,
        },
      },
      {
        '@context': 'https://schema.org',
        '@type': 'FAQPage',
        mainEntity: [
          {
            '@type': 'Question',
            name: 'Does FreeFormHelper.ai bypass Turnitin?',
            acceptedAnswer: { '@type': 'Answer', text: 'Yes. FreeFormHelper.ai rewrites AI-generated text using advanced natural language processing to produce output that passes Turnitin AI detection with a human score of 95-100%.' },
          },
          {
            '@type': 'Question',
            name: 'Is FreeFormHelper.ai free?',
            acceptedAnswer: { '@type': 'Answer', text: 'Yes, there is a free tier with 300 words per request (1 per day). Pro plan at €9.99/month gives 20,000 words. Premium at €24.99/month is unlimited.' },
          },
          {
            '@type': 'Question',
            name: 'Does it work with GPTZero and Originality.AI?',
            acceptedAnswer: { '@type': 'Answer', text: 'Yes. FreeFormHelper.ai is tested against all major AI detectors including Turnitin, GPTZero, Originality.AI, Copyleaks, and ZeroGPT.' },
          },
          {
            '@type': 'Question',
            name: 'What languages are supported?',
            acceptedAnswer: { '@type': 'Answer', text: 'FreeFormHelper.ai automatically detects the input language and outputs in the same language. It supports English, Spanish, French, German, Russian, and 20+ other languages.' },
          },
        ],
      },
    ]),
  },
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: metadata.other['application/ld+json'] }}
        />
      </head>
      <body className="antialiased">{children}</body>
    </html>
  );
}
