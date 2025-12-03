import { niches } from './seo-data';
export default function sitemap() {
  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'https://essay.codesaas.ie'; 
  const main = { url: baseUrl, lastModified: new Date().toISOString(), changeFrequency: 'daily', priority: 1 };
  const nicheUrls = Object.keys(niches).map((slug) => ({ url: `${baseUrl}/humanize/${slug}`, lastModified: new Date().toISOString(), changeFrequency: 'weekly', priority: 0.8 }));
  return [main, ...nicheUrls];
}
