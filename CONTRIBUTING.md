# Contributing

Thanks for considering a contribution to this repository.

## Before opening a pull request

1. Run `python3 scripts/check.py` and fix anything it flags.
2. If you changed the Terraform example, run `terraform fmt` and `terraform validate` in `examples/terraform/`.
3. If you added or changed a lab, make sure it includes: objective, prerequisites, starting state, steps, expected observations, verification, failure injection where safe, recovery, an explanation of why the result occurs, cleanup, and extension exercises — see the existing labs for the pattern.
4. Do not include employer names, customer data, account IDs, credentials, or internal URLs anywhere in the repository.

## What's welcome

- Corrections to technical inaccuracies, with a reference where possible.
- New labs that follow the existing contract and stay cost-aware.
- Additional interview questions with links back to working evidence in this repository.
- Troubleshooting scenarios written in the incident-contract format used in `docs/TROUBLESHOOTING.md`.

## What's not in scope here

- Live DDoS or attack-traffic testing against AWS infrastructure — see [`labs/03-shield-ddos-simulation-safe.md`](labs/03-shield-ddos-simulation-safe.md) for why.
- Auto-applying Terraform changes via CI — all applies in this repository are manual.

Use Issues for reproducible defects or improvement proposals, and Discussions for learning questions.
