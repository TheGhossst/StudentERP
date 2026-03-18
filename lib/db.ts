import { Pool, type QueryResultRow } from "pg";

declare global {
  var studentErpPool: Pool | undefined;
}

function createPool() {
  const connectionString = process.env.DATABASE_URL;

  if (!connectionString) {
    throw new Error(
      "DATABASE_URL is not set. Add it to your environment variables before starting the app.",
    );
  }

  return new Pool({
    connectionString,
    ssl:
      process.env.NODE_ENV === "production"
        ? { rejectUnauthorized: false }
        : false,
  });
}

export function getDbPool() {
  if (!global.studentErpPool) {
    global.studentErpPool = createPool();
  }

  return global.studentErpPool;
}

export async function dbQuery<T extends QueryResultRow>(
  queryText: string,
  params: unknown[] = [],
): Promise<T[]> {
  const pool = getDbPool();
  const result = await pool.query<T>(queryText, params);
  return result.rows;
}
