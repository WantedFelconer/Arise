export interface DBConfig {
  connectionString?: string;
  host?: string;
  port?: number;
  database?: string;
  user?: string;
  password?: string;
  max?: number;
}

class DatabaseConnectionManager {
  private pool: any = null;
  private isConnected = false;

  public initialize(config?: DBConfig): any {
    if (this.pool) {
      return this.pool;
    }

    try {
      // Dynamic import for server environment where pg is installed
      const pg = require('pg');
      const Pool = pg.Pool;
      this.pool = new Pool({
        connectionString: config?.connectionString || (typeof process !== 'undefined' && process.env?.DATABASE_URL) || 'postgresql://arise:arise_pass@localhost:5432/arise_db',
        max: config?.max || 20,
        idleTimeoutMillis: 30000,
        connectionTimeoutMillis: 5000,
      });

      this.pool.on('error', (err: any) => {
        console.error('[DB] Unexpected error on idle client', err);
      });
    } catch (e) {
      console.log('[DB] Running in-memory / browser fallback mode (pg native module omitted in client bundle)');
      this.pool = {
        query: async () => ({ rows: [], rowCount: 0 }),
        end: async () => {},
      };
    }

    this.isConnected = true;
    console.log('[DB] PostgreSQL pool initialized.');
    return this.pool;
  }


  public getPool(): any {
    if (!this.pool) {
      return this.initialize();
    }
    return this.pool;
  }

  public async query<T = any>(text: string, params?: any[]): Promise<{ rows: T[]; rowCount: number }> {
    const pool = this.getPool();
    const result = await pool.query(text, params);
    return {
      rows: result.rows,
      rowCount: result.rowCount || 0,
    };
  }

  public async close(): Promise<void> {
    if (this.pool) {
      await this.pool.end();
      this.pool = null;
      this.isConnected = false;
      console.log('[DB] Pool closed.');
    }
  }
}

export const dbManager = new DatabaseConnectionManager();
