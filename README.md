# Recruitment Application (with CI/CD pipeline)

This project is based on [JonathanVarild/IV1201-group7-recruitment-application](https://github.com/JonathanVarild/IV1201-group7-recruitment-application) and been extended with a CI/CD pipeline including automated tests, Docker images, and automated Terraform-based preview and production deployments to our Virtual Private Server (VPS).

See [report.pdf](report.pdf) for the project report.

## Local development

Requirements: Node.js 22, npm, and Docker.

1. Copy `.env.example` to `.env.local`.
2. Start the local database with `docker compose up -d`.
3. Install dependencies and start the application:

```sh
npm ci
npm run dev
```

The application is available at <http://localhost:3000>.

## Tests

```sh
npm run check
npm run test:integration
npm run test:e2e
```

Integration tests require PostgreSQL. End-to-end tests use `http://localhost:3000` by default or environment variable `PLAYWRIGHT_BASE_URL` when specified.

## Infrastructure

- `infra/terraform` manages preview and production application deployments.
- `infra/vps/docker-compose.yml` is the Docker compose configuration behind the VPS reverse proxy and TLS certificate companion.

Deployment requires:

- A VPS with Docker, SSH access for the `deploy` user, and the proxy stack running on the shared `dd2482-proxy` network.
- An HCP Terraform organization and production workspace.
- DNS for the production domain and wildcard preview domains pointing to the VPS.
- GitHub repository secrets: `HCP_TERRAFORM_TOKEN`, `DEPLOY_SSH_KEY`, `DB_PASSWORD`, and `SESSION_SECRET`.
