# Branching on a closed set of states in Kotlin — the short version

**The rule.** When you branch on a value whose set of cases is closed — an `enum class`, or a
`sealed` hierarchy — write the decision as **one `when` in expression position with no `else`**.
Expression position means the `when`'s value is *used*: returned, assigned to something, passed
as an argument, or the last expression of a lambda. Anything but discarded.

**Why that exact shape and not merely "a `when`".** Kotlin requires a `when` **used as an
expression** to be exhaustive. So the compiler — not a reviewer, not a test — holds the case
list. Add a constant to the enum tomorrow and this site stops compiling until someone decides
what the new case does.

The three shapes that lose that property, all of which compile today and all of which route a
new constant down a fallback path without telling anybody:

1. an `if` / `else if` / `else` chain,
2. a `when` that carries an `else` branch,
3. a `when` in **statement** position — its value discarded, used by nothing.

**What to do with the leftover cases you do not care about.** Do not reach for `else`. Name them
and give them the shared outcome explicitly: `IN_A, IN_B, IN_C -> refuse(...)`. The list is
longer to read and it is the whole point — the next person who adds a constant is forced to
decide, because the compiler asks them.

**One decision, one construct.** Splitting the same decision across two `when`s, or an `if`
wrapping a `when`, gives back the guarantee in a different way: neither construct alone is the
case list any more, so neither is compiler-enforced against the enum.

Details, with the compiler's own behaviour and the three shapes side by side:
`documents/kotlin-exhaustive-when.md`.
