# Context policy — v1.2

**This file is L3.** It states the policy; `.ai/hooks/retrieval-budget.sh` is the thing that
executes it, and `.ai/policies/retrieval-budget.yaml` holds the numbers that hook reads. If you
are looking for the boundary, it is the hook. This file is the reason the hook exists.

## The claim

Context is not free and it is not a scratchpad. Every file read, every search and every log dump
is paid for twice: once in tokens, and once in the attention it takes away from the three or four
facts that actually decide the change. **The failure this policy is written against is not
ignorance; it is a run that read thirty files and still wrote the wrong shape** — because by file
thirty nothing was load-bearing any more.

## What follows from it

1. **Search to locate, then stop.** Five searches is enough to find where a change goes. The sixth
   is almost always a search for reassurance, and reassurance is not information.
2. **Read to decide, not to know.** Fifteen files before the first edit is a generous ceiling for
   any change this service asks for. If fifteen were not enough, a sixteenth will not be either;
   what is missing is a decision, not a file.
3. **Never read a log whole.** The one line that matters is findable by name. A full surefire
   report is tens of thousands of lines of which you need one stack frame.
4. **A file you have already read has not changed unless you changed it.** Re-reading it is the
   purest form of this waste, because you are paying again for something you already have.
5. **Two similar implementations are enough to establish a pattern.** A third is confirmation
   bias with a file path. *(This one is NOT enforced — see
   `.ai/policies/retrieval-budget.yaml`, `max_similar_implementations`, and the reason it is
   L3: deciding that two files are the same SHAPE is a semantic judgement, and a phrase-matching
   approximation of it is a trap this project has already paid for.)*

## What this policy does not say

It does not say to guess. It does not say to skip the ticket, the file you are about to change, or
its test. Every limit here applies *before your first edit* except the log rule, and all of them
stop applying the moment you start writing. **The budget is a claim about when to start, not about
how carefully to work.**
