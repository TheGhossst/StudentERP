# Student ERP (Next.js + PostgreSQL)

This project is now connected to PostgreSQL and serves live dashboard data from the database.

## 1. Install dependencies

```bash
npm install
```

## 2. Configure environment variables

Create `.env.local` from `.env.example` and set your PostgreSQL URL:

```bash
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/studenterp
JWT_SECRET=change-this-to-a-long-random-secret
```

## 3. Create schema

Apply the schema file in `database/dbschema.sql`.

Example using `psql`:

```bash
psql -U postgres -d studenterp -f database/dbschema.sql
```

## 4. Run the app

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Connected routes

- Dashboard page: `/`
- Dashboard API: `/api/dashboard`
- Login API: `/api/auth/login`
- Current user API: `/api/auth/me`
- Logout API: `/api/auth/logout`

## Role-based authentication

This project now supports cookie-based JWT authentication using your PostgreSQL schema:

- Password check uses PostgreSQL `crypt(...)` against `users.password_hash`.
- Login attempts are recorded in `login_attempts` with IP address.
- Session cookie is `HttpOnly` and signed with `JWT_SECRET`.
- Role data is loaded from both `users.base_role` and scoped `user_roles`.
- Dashboard API access is restricted to:
	- Base roles: `admin`, `faculty`
	- Scoped roles: `advisor`, `HoD`, `placement_coordinator`

### Request format for login

`POST /api/auth/login`

```json
{
	"email": "admin.erp@nitgoa.ac.in",
	"password": "NitGoa@123"
}
```

### Sample seeded accounts (from insert script)

- Admin: `admin.erp@nitgoa.ac.in` / `NitGoa@123`
- Faculty (advisor): `ananya.sharma@nitgoa.ac.in` / `NitGoa@123`
- Student (CR): `aisha.khan24@nitgoa.ac.in` / `NitGoa@123`

## Implementation details

- Shared PostgreSQL pool lives in `lib/db.ts`.
- Dashboard queries live in `lib/dashboard.ts`.
- Auth helpers live in `lib/auth.ts`.
- Auth API routes live in `app/api/auth/login/route.ts`, `app/api/auth/me/route.ts`, and `app/api/auth/logout/route.ts`.
- Dashboard API route lives in `app/api/dashboard/route.ts`.
- If DB connection fails, the homepage shows a clear error state.
