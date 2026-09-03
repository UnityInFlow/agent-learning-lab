# Engineering handbook

This document collects the conventions this team has agreed on. It is long because it is
complete. Read it before you change anything in this repository.

## Working rules

- Prefer a construct that makes an unhandled case fail at compile time over one that lets it
  fall through at runtime.
- Run the module's verification command before reporting the work complete. If it fails, say
  so rather than reporting success.
- Follow the conventions already documented in the files you are changing.

## Repository layout

Source lives under `src/main/kotlin`, tests under `src/test/kotlin`, and the package tree
mirrors the domain rather than the technical layer. A package named for a domain concept holds
its controller, its service, its repository and its model together; a package named `util`,
`common`, `helpers` or `misc` is a sign that a concept has not been named yet. Resources live
under `src/main/resources`, and configuration that differs per environment belongs in a profile
file rather than in a conditional inside the code.

## Naming

Types are nouns and functions are verbs. A boolean reads as a predicate: `isConfirmed`,
`hasShipped`, `canCancel`. Avoid abbreviations that are not already in the domain's own
vocabulary; `qty` and `amt` save four characters and cost every future reader a translation
step. A variable named `data`, `info`, `obj`, `temp` or `result` names its type, not its role.
Constants are `UPPER_SNAKE_CASE` and live next to what they configure rather than in a shared
constants file, which becomes a dumping ground within a quarter.

## Formatting

Four spaces, no tabs. Lines wrap at 120 columns. One statement per line. Trailing commas in
multi-line argument lists so that adding a parameter is a one-line diff. Imports are never
wildcards: a wildcard import supplies symbols nobody asked for and makes the dependency of a
file on a package invisible. Do not reformat code you did not otherwise change; a formatting
change buried in a behavioural diff hides the behaviour.

## Kotlin idiom

Prefer `val` to `var`, and prefer immutable collections to mutable ones. Data classes for
values, sealed hierarchies for closed sets of alternatives. Use scope functions where they make
the subject obvious and avoid them where they hide it; a chain of four `let` calls is not
idiomatic, it is a puzzle. Nullability is part of the type: do not use `!!` to silence the
compiler, and do not use a platform type as an excuse to skip a null check. Extension functions
belong to the module that owns the receiver's meaning, not to whichever file needed them first.

## Spring conventions

Constructor injection only. Field injection makes a class untestable without a container and
hides its dependencies from its own signature. A controller translates HTTP into domain calls
and back, and holds no business logic. A service holds the logic and knows nothing about HTTP.
A repository holds persistence and knows nothing about either. `@Transactional` belongs on the
service, at the boundary of a unit of work, never on a controller method and never on a
repository method. Do not put a `@Component` on something that is only ever constructed by
hand.

## Error handling

Errors are part of the API. A refusal has a status, a stable machine-readable code, and a
message written for a human being. Do not leak an exception's class name or a stack trace into
a response body. Do not catch an exception in order to log it and rethrow it unchanged; the
handler at the boundary will log it once, and two log lines for one failure make an incident
harder to read, not easier. An empty catch block is never correct.

## Validation

Validate at the edge. A request object carries its own constraints, and a value that has been
validated should be represented by a type that cannot hold an invalid value, so that no code
downstream has to ask again. Prefer failing on the first invalid field with a clear message to
collecting every possible complaint into an unreadable list, unless the client is a form.

## Persistence

Every table has a primary key and a created timestamp. Migrations are forward-only and never
edited after they have run anywhere. A migration that cannot be run twice is not a migration.
Do not use a database default to express a business rule; the rule belongs where a reader will
look for it. An index is added with the query it exists for named in the migration's comment.

## Concurrency

Do not share mutable state across threads without a reason you can write down. Prefer an
immutable message to a lock. If you must lock, name the lock for what it protects, and never
hold two at once. A retry needs a bound and a backoff; an unbounded retry is an outage
amplifier. An operation that can be repeated should be idempotent, and the key that makes it
idempotent belongs in the request rather than being derived from the payload's shape.

## Testing

A test names the behaviour it protects, not the method it calls. Arrange, act, assert, with
blank lines between them. One reason to fail per test. Do not assert on a log line. Do not test
a framework's behaviour. Prefer a real collaborator to a mock where the real one is cheap, and
prefer a mock to a stub that has grown logic of its own. A test that has been failing for a
week and is still in the suite is documentation of a broken promise; either fix it or delete
it and file the gap.

## Test data

Build test data with a factory that takes overrides for the fields the test cares about, so
that a test reads as "a shipment, but cancelled" rather than as twelve irrelevant constructor
arguments. Do not reuse one shared fixture object across tests that mutate it.

## Logging

Log at the boundary, once per event, with the identifiers a reader will search for. Do not log
inside a loop. Do not log a secret, a token, a full request body, or a customer's personal
data. A log line that says "error" and nothing else costs the same to write and everything to
read.

## Dependencies

A new dependency is a commitment: it has a licence, a maintenance history, a transitive tree
and a security surface. Prefer the standard library. Prefer a dependency you already have to a
new one that is slightly better. Pin versions. Never add a dependency in the same change as the
feature that motivated it, so that either can be reverted alone.

## Configuration

Configuration is injected, never read from a static context. A default belongs in the
configuration file, not in the code that reads it, so that the full set of knobs is visible in
one place. A feature flag has an owner and a removal date.

## Documentation

A comment explains why, never what. If a comment is needed to explain what, the code needs a
name. Update the comment in the same change as the code it describes; a stale comment is worse
than none because it is trusted. A public type carries a KDoc sentence saying what it is for.

## Pull requests

One change per pull request. A pull request that touches unrelated files will be reviewed
worse, not faster. Write the description for someone who was not in the conversation. Include
what you did not do and why. A green build is a precondition for review, not a substitute for
it.

## Reviews

Review the change, not the person. Distinguish a blocking objection from a preference and say
which you are making. If you cannot say what would satisfy you, you are not making a review
comment. Approve when the change is better than the status quo, not when it is perfect.

## Performance

Measure before optimising, and measure the thing users wait for rather than the thing that is
easy to time. A cache is a correctness problem wearing a performance costume: name its
invalidation rule before you add it. Prefer an algorithmic fix to a micro-optimisation. Do not
add a thread pool to a problem you have not profiled.

## Security

Never trust input from outside the process. Escape at the point of use, not at the point of
entry, so that the escaping matches the sink. Secrets come from the environment and are never
committed, never logged and never included in an error message. An authorisation check belongs
where the resource is loaded, not where the route is declared.

## Deprecation

Mark it deprecated, give the replacement in the annotation, and remove it on a date you write
down. A deprecation with no removal date is a permanent second way to do the same thing.
