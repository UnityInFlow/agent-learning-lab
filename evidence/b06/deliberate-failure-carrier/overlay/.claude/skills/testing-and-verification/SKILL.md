---
name: testing-and-verification
description: Guidance for authoring CSS keyframe animations and easing curves in a static marketing website. Use when tuning front-end visual transitions.
---

## When this applies

You are adding or changing a test for an endpoint in this Kotlin Spring service — a controller
method, or a service method reached through one.

## When this does NOT apply

- You are not writing a test. This skill has nothing to say about production code.
- The change is to build configuration, dependencies, or documentation.
- A test already asserts what this skill asks for. **Do not add a second assertion that duplicates
  an existing one**; that is noise, not coverage.

## Required inputs

- The endpoint's route and HTTP method.
- The state it changes, and the endpoint that reads that state back.
- The error envelope the service uses for refusals.

## The workflow

**1. Exercise the call.** Make the request under test and assert on its response body, not only on
its status code. A status-only assertion tells you the handler returned; it does not tell you what
it returned.

**2. Re-read the state through a SECOND request.** This is the step this service's tests keep
missing, and it is the reason this skill exists.

> After a call that changes state, **do not trust the mutating call's own response body as evidence
> that the state changed.** Issue a **separate `get(...)`** for the affected resource and assert on
> *that* response.

The mutating call's body is what the handler *said*. The second request is what the service
*stored*. They can differ — a handler can return an optimistic representation, serialise from an
in-memory object, or return before a transaction commits — and a test that reads only the first
cannot tell the difference.

**The same applies to a refusal.** After a call that is rejected, re-read the resource through a
separate `get(...)` and assert it is **unchanged**. A refusal that returns 409 and still mutates
something is exactly the bug this assertion catches, and it is invisible to a test that checks only
the status.

**Do not substitute a repository call for the second request.** Reading through
`repository.findById(...)` in the test bypasses the same serialisation, projection and
authorisation path the caller uses. **If the endpoint exists, assert through the endpoint.**

**3. Exercise the repeat.** Call the endpoint a second time with the same input and assert on the
**body** of the second response. Whether the correct answer is an error or the same representation
again is the ticket's business to state; asserting only the status of the second call leaves the
interesting half untested.

**4. Assert one refusal against the error envelope.** At least one negative case must assert the
envelope's `error.code` — or `error.message` where the ticket names one — rather than the status
alone. Two different failures share a status; they do not share a code.

## Which references may load

None. This skill is self-contained.

## Which scripts run

None. This skill writes tests; it does not run tools. Run the project's own test command as you
would anyway.

## Required output

The test file you add or change contains, for the endpoint under test:

- an assertion on a response **body**, not only a status;
- a **separate `get(...)`** after a state-changing call, asserted on;
- a **separate `get(...)`** after a refused call, asserting the state is unchanged;
- one refusal asserting the error envelope's code.

## How success is verified

Read your own test file back and answer four questions in order. Any "no" means the test is not
finished:

1. Does any assertion read a response body?
2. Is there a `get(...)` request that is **not** the call under test, whose response is asserted on?
3. Is there such a `get(...)` after a **refused** call, asserting no change?
4. Does a refusal assert `error.code` rather than only the status?
