# Branching on a closed set of states in Kotlin — the long version

This document exists because the shape of a status decision is the difference between *the
compiler keeps the case list* and *a future maintainer finds out in production*. It is about the
Kotlin language rule and nothing else: no ticket, no endpoint, no domain type.

## 1. The rule, stated precisely

A `when` used **as an expression** must be exhaustive, or the code does not compile. "As an
expression" means its value is consumed:

```kotlin
// returned
return when (phase) { … }

// assigned
val outcome = when (phase) { … }

// passed as an argument
respond(when (phase) { … })

// the last expression of a lambda
items.map { when (it.phase) { … } }
```

A `when` used as a **statement** — its value dropped on the floor — carries no such requirement:

```kotlin
when (phase) {          // statement position: nothing consumes the value
    Phase.DRAFT -> log("draft")
    Phase.OPEN  -> log("open")
}                       // compiles happily while CLOSED is unhandled
```

Both fragments look like "a `when` over the phase". Only the first one is a case list the
compiler enforces.

## 2. The three shapes that silently absorb a new case

Given `enum class Phase { DRAFT, OPEN, CLOSED }`:

```kotlin
// (a) if / else if / else — a new constant falls into the final else
if (phase == Phase.DRAFT) { … }
else if (phase == Phase.OPEN) { … }
else { refuse() }                     // ARCHIVED lands here, unannounced

// (b) when with else — same hole, different syntax
when (phase) {
    Phase.DRAFT -> …
    Phase.OPEN  -> …
    else        -> refuse()           // ARCHIVED lands here, unannounced
}

// (c) when in statement position — no exhaustiveness requirement at all
when (phase) {
    Phase.DRAFT -> doThing()
    Phase.OPEN  -> doOtherThing()
}
```

All three compile the day they are written. All three keep compiling the day a constant is added.
That is the defect: nothing fails, so nobody looks.

## 3. The shape that does not

```kotlin
val result: Outcome = when (phase) {     // expression position — value assigned
    Phase.DRAFT  -> Outcome.Prepare
    Phase.OPEN   -> Outcome.Proceed
    Phase.CLOSED -> Outcome.Refuse
}                                        // no else: the compiler holds the case list
```

Add `Phase.ARCHIVED` to the enum and this file stops compiling with
`'when' expression must be exhaustive, add necessary 'ARCHIVED' branch or 'else' branch instead`
— which is the message you want, at the site that has to decide.

## 4. Grouping cases without giving up the guarantee

The instinct when several constants share an outcome is `else`. Name them instead:

```kotlin
val result: Outcome = when (phase) {
    Phase.OPEN                 -> Outcome.Proceed
    Phase.DRAFT, Phase.CLOSED  -> Outcome.Refuse      // grouped, still exhaustive
}
```

Same behaviour today; different behaviour in six months, which is when it matters.

## 5. One decision, one construct

```kotlin
// gives back the guarantee without looking like it does
if (phase == Phase.CLOSED) return Outcome.Refuse
val result = when (phase) {              // now covers only the remaining constants
    Phase.DRAFT -> …
    Phase.OPEN  -> …
    else        -> Outcome.Refuse         // and needs an else again, because the first
}                                         // construct took a case away from it
```

If the decision is split, no single construct is the case list, so no single construct is
compiler-checked against the enum. Keep the whole decision in one `when`.

## 6. The same argument for `sealed`

A `sealed class` or `sealed interface` has a closed set of direct subtypes, and a `when` over it
in expression position is exhaustive for the same reason. `is` checks with a trailing `else`
lose the property in exactly the way `(b)` above does.

## 7. What this document does not claim

It says nothing about how any particular refusal should be represented, what any particular
state means, or which states any particular system has. It is a language rule and a shape. The
decision about *which* cases exist, and what each one does, is the task's, not this document's.
