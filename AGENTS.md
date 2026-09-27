# Research instructions

Read the [fixed question](campaigns/noncrossing-theta-recognition/question.md), [prior state](campaigns/noncrossing-theta-recognition/state.md) and [preparation notes](campaigns/noncrossing-theta-recognition/work/preparation.md). The fixed [test corpus](campaigns/noncrossing-theta-recognition/work/cases.json) and [verifier](campaigns/noncrossing-theta-recognition/work/check.py) are the starting evidence; the preparation notes state their coverage and any pending checks.

Run `uv sync --locked`, then `uv run --locked python campaigns/noncrossing-theta-recognition/work/check.py --self-test` before relying on that evidence. Follow the current user's AutoResearch pipeline. Scope and budgets in the state describe earlier work and do not limit a new campaign. Preserve prior evidence, commit new work incrementally and make only evidence-backed claims.
