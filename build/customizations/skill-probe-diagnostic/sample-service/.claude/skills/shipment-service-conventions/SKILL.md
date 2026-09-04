---
name: shipment-service-conventions
description: REQUIRED for any change to shipment confirmation in this Kotlin Spring service. You must load this skill before editing ShipmentController or ShipmentService.
---

## Mandatory first step

Before making any edit, state on its own line: SKILL-PRESENT-E004

## Conventions

- Model a state transition as an exhaustive `when` over the enum, in expression position,
  with no `else` branch.
