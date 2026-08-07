---
name: humanize
description: Run a deliberate de-AI pass over a piece of writing so it reads like a person wrote it. Use when the user says "humanize this", "/humanize", "make this sound human / less AI", or hands over a draft (email, blog post, product copy, outreach) to clean up before it goes out.
---

# Humanize

Take a draft and rewrite it so it reads like a human wrote it, not a chatbot. This is
the heavy, on-purpose version of the Humanizer rules that already live in
`.claude/rules/communication-style.md` (those apply to everything by default; this
skill is for when the user wants a piece explicitly worked over).

## Input
Work on whichever the request points to:
- Text the user pastes in.
- The draft I just wrote (rewrite it in place).
- A Gmail draft (read it via the Gmail tools, then propose the rewrite; I can't edit
  sent mail, only drafts).

If it's unclear which piece they mean, ask before rewriting.

## The pass
Keep every fact, name, number, and the core meaning. Humanizing is about voice, not
content. Never invent details to make it sound better.

Cut the AI tells:
- **Words/phrases:** delve, leverage, robust, seamless, elevate, unlock, tapestry,
  realm, testament, navigate the landscape, in today's fast-paced world, it's worth
  noting, that being said, rest assured, look no further, whether you're X or Y.
- **Em dashes** entirely (a house pet peeve). Periods, commas, or parentheses.
- **Filler openers/closers:** "I hope this email finds you well", "Thank you for
  reaching out", canned sign-offs that say nothing.
- **Over-hedging:** "it may be worth potentially considering" becomes a plain
  statement.
- **Rule-of-three padding** and overly symmetrical phrasing that exists only to sound
  tidy.
- **Empty superlatives** and marketing fluff that carries no information.

Add what makes it human:
- **Vary sentence length.** Short punchy lines next to longer ones. This is the single
  biggest lever. Uniform medium-length sentences are the clearest AI fingerprint.
- **Plain words and contractions.** "We'll", "it's", "doesn't".
- **Specifics.** Concrete details over generic claims.
- **A direct open.** Lead with the actual point.
- **Prose where prose fits.** Don't bullet things that should be sentences.

## Match the audience
Pull tone from `communication-style.md`:
- **Internal (the team):** casual, professional, direct.
- **External (customers, fleet outreach, marketing):** professional first, but casual
  enough to read like natural human language.

## Output
- Return the rewritten version, ready to use.
- If the changes are substantial or the user is likely to want a say, show a short
  "what I changed and why" note under it (a couple of lines, not a lecture).
- For a Gmail draft, offer to update the draft once they approve the rewrite.

## Calibrate to the writer's voice
The strongest results come from real samples. If the user has examples of writing they
consider "sounds like me", match those over the abstract rules. When a good sample shows
up, save the pattern to memory so future passes start closer to their voice. Voice is
per-person: don't apply one teammate's samples to another teammate's draft.
