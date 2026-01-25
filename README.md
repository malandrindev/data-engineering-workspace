# Data Engineering Workspace

This repository consolidates practical Data Engineering patterns,
covering SQL analytics, data pipelines, orchestration, and analytical modeling.

The focus is on reproducible, production-oriented approaches using synthetic data
to represent real enterprise scenarios such as ERP systems, e-commerce platforms,
and system integrations.

This workspace is designed to document decision-making, trade-offs, and
implementation patterns commonly encountered in Data Engineering roles.

---

## Environment

Local development environment configured with:

- Windows + WSL2
- Docker & Docker Compose
- PostgreSQL (containerized)
- VS Code
- DBeaver

---

## Repository Structure

- `00-labs` — isolated technical labs and tooling experiments
- `01-sql-foundations` — core SQL analytical patterns and performance considerations
- `02-etl-python` — ETL pipelines implemented in Python
- `03-orchestration` — workflow orchestration and scheduling concepts
- `04-analytics-modeling` — analytical and dimensional modeling patterns
- `shared` — reusable utilities, SQL templates, and documentation
- `archive` — legacy files and reference material

---

## Notes

All datasets are synthetic and intentionally small to allow full control over
data relationships, query behavior, and performance characteristics.
