# todo-backend plan

## Milestones

### 1) Core Setup
- Create project structure under `src/`
- Setup Express app + security middleware (cors, helmet, rate-limit)
- Setup MongoDB connection (MongoDB Atlas)
- Global error handler + consistent response format
- Health endpoint

### 2) Authentication & Authorization
- User model (bcrypt hashing)
- JWT access/refresh tokens
- Endpoints: register/login/logout/refresh/me/update
- Role-based authorization

### 3) Tasks Management
- Task model + CRUD
- Filtering/sorting/pagination
- Toggle status
- Stats endpoint

### 4) Shared Lists
- List model + member roles (viewer/editor/admin)
- Invite + join by code
- Public lists

### 5) Achievements + Activity Logs
- Achievement model + check endpoint
- Activity log model + hooks

### 6) Sync System
- Sync endpoint + lastSyncAt
- Conflict resolution (updatedAt based)

### 7) Notifications
- Notification service (email via Nodemailer)
- Optional Socket.io for realtime

### 8) Delivery
- Postman collection
- README with examples + Atlas setup + Render/Railway deployment notes
- .env.example
