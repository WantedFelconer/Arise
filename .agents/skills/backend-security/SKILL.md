---
name: backend-security
description: Implements non-functional requirements including user authentication, authorization middleware, CORS configuration, rate limiting, and performance layers.
---

## 5. Non-Functional Requirements

| ID | Category | Requirement |
|---|---|---|
| NFR-PERF-1 | Performance | Local (offline) interactions SHALL complete within ~100ms perceived latency. |
| NFR-PERF-2 | Performance | Backend API p95 response time SHALL be under 300ms for non-AI endpoints under nominal load. |
| NFR-PERF-3 | Performance | AI-dependent endpoints (plan generation, triage, reflection) SHALL respond asynchronously (job + polling or websocket push) rather than holding an HTTP connection open indefinitely. |
| NFR-REL-1 | Reliability | No user data SHALL be lost due to temporary connectivity loss; the local event queue SHALL persist across app restarts/crashes. |
| NFR-REL-2 | Reliability | Synchronization SHALL be resilient to crashes and interruptions mid-sync (resumable, idempotent). |
| NFR-SCALE-1 | Scalability | The event synchronization pipeline SHALL be designed to scale horizontally (stateless API instances behind a load balancer, queue-backed workers) to support growth toward millions of users. |
| NFR-MAINT-1 | Maintainability | Synchronization logic SHALL be modular and independently testable from feature business logic. |
| NFR-MAINT-2 | Maintainability | Every backend module and frontend feature SHALL contain a README documenting purpose, public API, dependencies, DB tables, events, and extension points. |
| NFR-SEC-1 | Security | Client-generated progression data MUST always be validated by the backend before becoming authoritative (see FR-VALID-1). |
| NFR-SEC-2 | Security | All traffic SHALL use TLS; all sensitive data at rest SHALL be encrypted. |
| NFR-SEC-3 | Security | The system SHALL implement Role-Based Access Control and per-resource ownership checks. |
| NFR-ACC-1 | Accessibility | The UI SHALL meet baseline mobile accessibility guidelines (sufficient contrast, scalable text, screen-reader labels on primary interactive elements). |
| NFR-OFFLINE-1 | Offline Support | Nearly all productivity actions SHALL function fully offline, per Section 3.2 and 4.27. |
| NFR-PRIV-1 | Data Privacy | The system SHALL allow users to export and delete their data (right to portability/erasure). |
| NFR-LOG-1 | Logging/Monitoring | All API errors and all progression-affecting events SHALL be logged with correlation IDs for traceability. |
| NFR-API-1 | API Versioning | The API SHALL be versioned under `/api/v1/` to allow non-breaking evolution. |
| NFR-CACHE-1 | Caching | Frequently-read, slow-to-compute aggregates (e.g., monthly analytics) SHALL be cached in Redis with explicit invalidation on relevant events. |
| NFR-SYNC-1 | Synchronization | Sync SHALL occur asynchronously and SHALL NOT block UI interaction (see NFR-PERF-1). |

---