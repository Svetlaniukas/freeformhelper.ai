import { niches } from './seo-data';

export default function sitemap() {
  const baseUrl = 'https://freeformhelper.ai';

  const main = {
    url: baseUrl,
    lastModified: new Date().toISOString(),
    changeFrequency: 'daily',
    priority: 1.0,
  };

  const pricing = {
    url: `${baseUrl}/#pricing`,
    lastModified: new Date().toISOString(),
    changeFrequency: 'monthly',
    priority: 0.9,
  };

  const nicheUrls = Object.keys(niches).map((slug) => ({
    url: `${baseUrl}/humanize/${slug}`,
    lastModified: new Date().toISOString(),
    changeFrequency: 'weekly',
    priority: 0.85,
  }));

  return [main, pricing, ...nicheUrls];
}
