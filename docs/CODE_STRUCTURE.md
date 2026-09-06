# Code structure

| Path | Contents | Why it's separate |
|---|---|---|
| `README.md` | Entry point, architecture summary, learning path, repository map | First screen must answer what/why/where without opening another file |
| `docs/ARCHITECTURE.md` | Full request-flow narrative, design decisions, trade-offs | Kept out of the README so the README stays scannable |
| `docs/END_TO_END_GUIDE.md` | The single ordered path through the whole repo | One canonical route, so there's no ambiguity about where to start |
| `docs/CODE_STRUCTURE.md` | This file | Explains the "why" behind the layout itself |
| `docs/SECURITY.md` | Shield/WAF/OAC design rationale and a hardening checklist | Separated from the repository-level `SECURITY.md` (vulnerability reporting policy) at the root |
| `docs/COST_AND_CLEANUP.md` | Per-lab cost estimate and teardown command | Cost is a first-class concern, not a footnote |
| `docs/TROUBLESHOOTING.md` | Incident-style scenarios: symptom → root cause → fix → prevention | Written as reproducible investigations, not a FAQ |
| `docs/INTERVIEW_QUESTIONS.md` | Fundamentals through architect-level questions, linked to evidence in this repo | Interview prep that references real, working material instead of memorized answers |
| `docs/ROADMAP.md` | This repository's place in the wider `jeevanm84` portfolio | Keeps portfolio-wide claims out of this repo's own README |
| `diagrams/` | The architecture SVG | Single source of truth for the visual, referenced from multiple docs |
| `labs/` | Ordered, cost-aware, hands-on AWS exercises | Each lab is self-contained: objective, prerequisites, steps, verification, cleanup |
| `examples/terraform/` | A minimal, commented CloudFront + S3 + OAC + WAF skeleton | For reading and manual `terraform apply`, not auto-deployed by CI |
| `scripts/check.py` | Markdown structure, local link, and identity-leak validation | Runs locally and in CI before any content is trusted as "published" |
| `.github/` | CI workflow, issue templates, PR template, CODEOWNERS, Dependabot | Keeps contribution and automation config out of the documentation tree |
