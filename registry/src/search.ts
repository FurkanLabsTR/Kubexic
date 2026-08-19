export interface SearchParams {
  query?: string;
  page: number;
  perPage: number;
  sort: 'relevance' | 'downloads' | 'recent' | 'name';
}

export interface SearchResult {
  name: string;
  description: string;
  latest_version: string | null;
  download_count: number;
  updated_at: string;
  owner: string;
}

export function parseSearchParams(url: URL): SearchParams {
  const page = Math.max(1, parseInt(url.searchParams.get('page') || '1', 10));
  const perPage = Math.min(100, Math.max(1, parseInt(url.searchParams.get('per_page') || '20', 10)));

  const validSorts = ['relevance', 'downloads', 'recent', 'name'];
  const rawSort = url.searchParams.get('sort') || 'relevance';
  const sort = validSorts.includes(rawSort) ? (rawSort as SearchParams['sort']) : 'relevance';

  const query = url.searchParams.get('q') || url.searchParams.get('query') || undefined;

  return { query, page, perPage, sort };
}

export async function searchPackages(
  db: D1Database,
  params: SearchParams
): Promise<{ results: SearchResult[]; total: number }> {
  const { query, page, perPage, sort } = params;
  const offset = (page - 1) * perPage;

  let whereClause = '';
  let orderClause = '';
  const bindings: unknown[] = [];

  if (query) {
    whereClause = 'WHERE (p.name LIKE ? OR p.description LIKE ?)';
    bindings.push(`%${query}%`, `%${query}%`);
  }

  switch (sort) {
    case 'downloads':
      orderClause = 'ORDER BY p.download_count DESC, p.updated_at DESC';
      break;
    case 'recent':
      orderClause = 'ORDER BY p.updated_at DESC';
      break;
    case 'name':
      orderClause = 'ORDER BY p.name ASC';
      break;
    default:
      if (query) {
        orderClause = `ORDER BY
          CASE WHEN p.name = ? THEN 0
               WHEN p.name LIKE ? THEN 1
               ELSE 2
          END, p.download_count DESC`;
        bindings.push(query, `${query}%`);
      } else {
        orderClause = 'ORDER BY p.download_count DESC, p.updated_at DESC';
      }
  }

  const countQuery = `SELECT COUNT(*) as total FROM packages p ${whereClause}`;
  const { results: countResults } = await db
    .prepare(countQuery)
    .bind(...bindings)
    .all<{ total: number }>();
  const total = countResults?.[0]?.total || 0;

  const dataQuery = `
    SELECT p.name, p.description, p.latest_version, p.download_count, p.updated_at,
           u.username as owner
    FROM packages p
    JOIN users u ON p.owner_id = u.id
    ${whereClause}
    ${orderClause}
    LIMIT ? OFFSET ?
  `;
  const dataBindings = [...bindings, perPage, offset];

  const { results } = await db
    .prepare(dataQuery)
    .bind(...dataBindings)
    .all<SearchResult>();

  return { results: results || [], total };
}
