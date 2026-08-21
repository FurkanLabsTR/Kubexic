# Kubexic Project — Communication & Workflow Preferences

## User Communication Style
- User prefers continuous work without stopping — "don't stop", "proceed", "continue"
- When blocked, explain the root cause clearly and propose the next step
- Summarize progress in tables when comparing what works vs what doesn't
- Be honest about what's working vs what's scaffolding

## Workflow
- Always verify with tests after each change
- Use `grep -v warning` to filter noise from build output
- Check generated IR (`output.ll`) to debug codegen issues
- Use `addr2line` for crash diagnosis
- Binary search with probe programs for isolating codegen bugs
