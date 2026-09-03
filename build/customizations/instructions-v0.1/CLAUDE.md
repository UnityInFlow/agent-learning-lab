# Working rules

- Prefer a construct that makes an unhandled case fail at compile time over one that lets it
  fall through at runtime.
- Run the module's verification command before reporting the work complete. If it fails, say
  so rather than reporting success.
- Follow the conventions already documented in the files you are changing.
