# Global Agent Instructions

## Identity

- You are assisting a senior software engineer who values concise, direct communication.
- Skip flattery and filler. Get to the point.

## Coding Conventions

- Prefer minimal, readable code over verbose implementations.
- Use descriptive variable names; avoid abbreviations except well-known ones (e.g., `ctx`, `err`, `req`).
- Follow the language's idiomatic style and conventions.
- Include comments only when the "why" isn't obvious from the code. Never write comments that restate what the code does (e.g., `// increment counter` above `counter++`). Comments must add context, rationale, or warn about non-obvious behavior — not narrate the implementation.

## Design Principles

- Follow the Law of Demeter: objects should only talk to their immediate collaborators, not reach through chains (e.g., `a.getB().getC().doThing()` is a violation).
- Use dependency injection: pass dependencies in through constructors or function parameters rather than creating them internally. This supports the Open/Closed Principle (extend behavior without modifying existing code) and the Single Responsibility Principle (each unit does one thing and delegates the rest).
- Prefer composition over inheritance.

## Workflow Preferences

- When making changes, explain what you're doing and why.
- Prefer small, focused changes over large refactors.
- Don't add tests unless explicitly asked.
- Don't modify existing tests unless explicitly asked.

## Unit Testing

- Prefer table-driven/parameterized tests that cover edge cases.
- Each test should verify a single concept with one main assertion.
- Tests must be self-contained: no reading environment variables, no filesystem access, no network calls, no reliance on external state.
- Tests must not modify the environment (no setting env vars, no writing files, no global state mutation).
- All environment interactions (filesystem, network, env vars, time, etc.) must go through injectable interfaces. Use mocks/stubs in tests.

## Security

- Never include secrets, API keys, or credentials in code.
- Use environment variables or secret management for sensitive values.
- Follow the principle of least privilege.

## Publishing applications to Coolify

Coolify lives at <https://coolify.stolworthy.co>, hosted on a dedicated Debian VM (`spencer@10.0.0.86`) on the same Proxmox host as the k3s cluster but completely separate from it. Use it for non-k8s apps (anything containerized that doesn't need cluster primitives).

### Setting up a new app

1. The repo needs a `Dockerfile` at its root. The image should:
   - `EXPOSE` the listening port (Coolify auto-detects, but be explicit).
   - Declare a `HEALTHCHECK` that hits `/healthz` (or equivalent) and returns 200 — Coolify uses it to gate rolling deploys.
   - Declare `VOLUME ["/data"]` for any persistent state.
2. In the Coolify UI: New Application → connect the GitHub repo → branch `main` → Dockerfile-based build. Set the FQDN under Domains.
3. Set environment variables in Coolify's "Environment Variables" tab. **Never** put secrets in the repo.

### Config: bake it into the image, do not use Coolify file storage as source of truth

Coolify's "file storage" feature mounts a host file into the container (`/data/coolify/applications/<uuid>/config/<file>` → wherever you want). It's editable from the UI, but it lives outside git, so a volume rebuild or environment migration silently loses your edits. Instead:

- `COPY config.yaml /app/config.yaml` in the Dockerfile.
- Set `ENV CONFIG_PATH=/app/config.yaml` (or whatever path the app reads).
- All future config changes go through git → push → auto-deploy.

### Deploys

- A push to `main` triggers a GitHub webhook → Coolify rebuilds and rolls. **Verify it actually fired** in the Coolify UI's Deployments tab — auto-deploy has gone silent on some projects without warning. If broken, manually queue a deploy from the UI or via the Coolify API.
- The container name pattern on the host is `<resource_uuid>-<deployment_id>`. The `deployment_id` changes per deploy, so find the current one with `sudo docker ps --format '{{.Names}}' | grep '^<resource_uuid>-'`.
- Confirm boot by tailing `sudo docker logs --since 5m <name>` for the app's expected "listening on" line.

### Public routing

- For subdomains under `*.coolify.stolworthy.co`: just set the FQDN in the Coolify app settings. Coolify provisions a Let's Encrypt cert and the in-cluster `cloudflared` already has a wildcard route to the host.
- For other `stolworthy.co` subdomains (no `.coolify.` prefix): add the hostname to `apps.cloudflared.publicServices` in the `homeassistant` repo's `config/values.yaml`, with an explicit `service: https://10.0.0.86` override. ArgoCD picks it up after sync.
- Cloudflare SSL/TLS mode should be **Full (Strict)** for the zone.

### Authentik SSO

- Create the OIDC blueprint at `apps/authentik/blueprints/<app>-oidc.yaml` in the `homeassistant` repo. Add the Coolify callback URL as the redirect URI.
- Seal the client ID/secret into `apps/authentik/secrets.yaml` (the existing `authentik-secrets` envFrom block on the Authentik server/worker pods picks them up — no deployment change needed).
- Apply the blueprint manually inside the Authentik server pod after ArgoCD syncs — the PostSync hook is unreliable. See the `homeassistant` README's "SSO (Authentik) — known issue" section for the exact `kubectl exec` invocation.
- Coolify v4 has no env-var path for its own OIDC config, so the final wiring is a one-time UI step (Settings → Authentication): paste issuer, client ID, client secret, redirect URI, test sign-in.

### Persistent storage

- Volumes declared in the Dockerfile materialize at `/var/lib/docker/volumes/<resource_uuid>-<volume>/_data/` on the host.
- Coolify does **not** back these up. For data you can't lose, write a periodic dump from inside the container to a path that's covered by an external backup (NAS rsync, S3, etc.) — same pattern as the database dump CronJobs in the k3s cluster.
