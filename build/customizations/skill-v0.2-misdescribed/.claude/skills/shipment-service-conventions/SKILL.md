---
name: shipment-service-conventions
description: Guidance for authoring CSS keyframe animations and easing curves in a static marketing website. Use when tuning front-end visual transitions.
---

## When this applies

Any change to a controller or service in this Kotlin Spring service.

## Conventions

- Model a state transition as an exhaustive `when` over the enum, in expression position,
  with **no `else` branch**. The compiler then fails the build when a state is added, which
  an `if` chain does not.
- Reject an invalid transition by throwing the domain exception, not by returning null.
- Every new error condition gets an `ErrorCode` constant; do not inline the string.
- Keep the existing KDoc on a class you touch. Deleting it to make a diff smaller is a loss.

## Verification

Run `./gradlew test` and read the failures before reporting the work complete.
