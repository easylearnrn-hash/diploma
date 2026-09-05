// Institution search for the admission form's autocomplete.
// Provides WORLDWIDE coverage: merges a curated, server-side Armenian
// institutions table (for accurate official Armenian names) with a
// broader external universities API covering every country, so no
// large database is ever shipped to the browser — only the top
// matches are returned, on demand, per keystroke.
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const MAX_RESULTS = 10
const EXTERNAL_API_TIMEOUT_MS = 2500

interface InstitutionResult {
  name: string
  city: string
  state: string
  country: string
  source: 'verified' | 'external'
  aliases?: string[]
}

// Punctuation-insensitive normalization: institution names vary in comma/period
// usage (e.g. "University of California, Los Angeles") which breaks naive
// substring matching when applicants type without the punctuation. Strips all
// non-alphanumeric characters down to single spaces so comparisons are fair.
function normalizeForMatch(value: string): string {
  return (value || '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, ' ')
    .trim()
    .replace(/\s+/g, ' ')
}

function tokenize(value: string): string[] {
  const normalized = normalizeForMatch(value)
  return normalized ? normalized.split(' ') : []
}

// Generic words that make poor search anchors on their own (too many matches).
const GENERIC_TOKENS = new Set([
  'university', 'college', 'institute', 'institution', 'school', 'academy',
  'polytechnic', 'the', 'of', 'and', 'state', 'national', 'international',
])

// Picks the single most distinctive word to send to the external API (which
// only supports one substring per request). Prefers longer, less generic
// words so a multi-word query like "university of california los angeles"
// anchors on something like "angeles" or "california" instead of "university".
function pickExternalAnchor(tokens: string[]): string {
  const candidates = tokens.filter((t) => t.length >= 3 && !GENERIC_TOKENS.has(t))
  const pool = candidates.length ? candidates : tokens
  if (!pool.length) return ''
  return pool.reduce((best, current) => (current.length >= best.length ? current : best))
}

function relevanceScore(name: string, query: string): number {
  const n = normalizeForMatch(name)
  const q = normalizeForMatch(query)
  if (n === q) return 100
  if (n.startsWith(q)) return 80
  const idx = n.indexOf(q)
  if (idx === -1) return 0
  // Earlier matches and shorter names score slightly higher (closer match)
  return 60 - Math.min(idx, 20) - Math.min(n.length / 10, 10)
}

// Best score across the official name and any known abbreviations/aliases,
// so e.g. "ACNHS" ranks its full institution highly even though the
// abbreviation isn't a literal substring of the official name.
function bestRelevanceScore(item: InstitutionResult, query: string): number {
  const scores = [relevanceScore(item.name, query), ...(item.aliases || []).map((alias) => relevanceScore(alias, query))]
  return Math.max(...scores)
}

async function searchVerifiedInstitutions(query: string): Promise<InstitutionResult[]> {
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
  const { data, error } = await supabase
    .rpc('search_institutions_fuzzy', { q: query, max_results: MAX_RESULTS })

  if (error) {
    console.error('Verified institutions query failed:', error.message)
    return []
  }

  return (data || []).map((row) => ({
    name: row.name,
    city: row.city || '',
    state: row.state || '',
    country: row.country || '',
    aliases: row.aliases || [],
    source: 'verified' as const,
  }))
}

async function searchExternalInstitutions(query: string): Promise<InstitutionResult[]> {
  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), EXTERNAL_API_TIMEOUT_MS)

  const tokens = tokenize(query)
  // Send the most distinctive single word as the anchor (the public API only
  // supports one substring per request), then AND-filter the returned
  // candidates client-side against every token so punctuation differences
  // (commas, periods) between the applicant's input and the official name
  // don't cause valid matches to be missed.
  const anchor = pickExternalAnchor(tokens) || query

  try {
    // NOTE: this public API only serves plain HTTP (no HTTPS listener) — safe
    // here since the request originates server-side, never from the browser.
    const response = await fetch(
      `http://universities.hipolabs.com/search?name=${encodeURIComponent(anchor)}`,
      { signal: controller.signal }
    )

    if (!response.ok) return []

    const data = await response.json()
    if (!Array.isArray(data)) return []

    // The public universities API covers every country but only provides
    // state/province — not city — so city is left blank for these results.
    const mapped = data.map((item: Record<string, unknown>) => ({
      name: String(item.name || ''),
      city: '',
      state: String((item as { ['state-province']?: string })['state-province'] || ''),
      country: String(item.country || ''),
      source: 'external' as const,
    })).filter((item) => item.name)

    // Keep only candidates containing every token from the applicant's query
    // (order-independent, punctuation-insensitive) so the broader anchor
    // search doesn't flood results with unrelated same-word institutions.
    const filtered = tokens.length > 1
      ? mapped.filter((item) => {
          const normalizedName = normalizeForMatch(item.name)
          return tokens.every((token) => normalizedName.includes(token))
        })
      : mapped

    return filtered.slice(0, MAX_RESULTS)
  } catch (error) {
    console.error('External institution search failed or timed out:', (error as Error).message)
    return []
  } finally {
    clearTimeout(timeout)
  }
}

function mergeAndRank(query: string, verified: InstitutionResult[], external: InstitutionResult[]): InstitutionResult[] {
  const merged: InstitutionResult[] = [...verified]
  const seenNames = new Set(verified.map((item) => normalizeForMatch(item.name)))

  for (const item of external) {
    const key = normalizeForMatch(item.name)
    if (seenNames.has(key)) continue
    seenNames.add(key)
    merged.push(item)
  }

  return merged
    .map((item) => ({ item, score: bestRelevanceScore(item, query) + (item.source === 'verified' ? 5 : 0) }))
    .sort((a, b) => b.score - a.score)
    .slice(0, MAX_RESULTS)
    .map((entry) => ({
      name: entry.item.name,
      city: entry.item.city,
      state: entry.item.state,
      country: entry.item.country,
      source: entry.item.source,
    }))
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { query } = await req.json()
    const trimmedQuery = (query || '').toString().trim()

    if (trimmedQuery.length < 2) {
      return new Response(JSON.stringify({ results: [] }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const [verified, external] = await Promise.all([
      searchVerifiedInstitutions(trimmedQuery).catch(() => []),
      searchExternalInstitutions(trimmedQuery).catch(() => []),
    ])

    const results = mergeAndRank(trimmedQuery, verified, external)

    return new Response(JSON.stringify({ results }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(
      JSON.stringify({ error: (error as Error).message, results: [] }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
