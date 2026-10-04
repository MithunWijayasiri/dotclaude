# Structures to Avoid

Each pattern below is a default, not an absolute. Keep any construction that
carries a fact, a real contrast, a required register, or a qualifier the claim
depends on. See SKILL.md Scope.

## Binary Contrasts

These create false drama. State the point directly.

| Pattern | Problem |
|---------|---------|
| "Not because X. Because Y." / "Not because X, but because Y." | Telegraphed reversal |
| "[X] isn't the problem. [Y] is." | Formulaic reframe |
| "The answer isn't X. It's Y." | Predictable pivot |
| "It feels like X. It's actually Y." | Setup/reveal cliche |
| "The question isn't X. It's Y." | Rhetorical misdirection |
| "Not X. But Y." / "not X, it's Y" / "isn't X, it's Y" | Mechanical contrast |
| "It's not this. It's that." | Same formula, different words |
| "stops being X and starts being Y" | False transformation arc |
| "doesn't mean X, but actually Y" | Negation-then-assertion crutch |
| "is about X but not Y" | False distinction |
| "not just X but also Y" | Additive hedge |

**Instead:** State Y directly. "The problem is Y." "Y matters here." Drop the negation entirely.

## Negative Listing

Listing what something is *not* before revealing what it *is*. A rhetorical striptease.

| Pattern | Problem |
|---------|---------|
| "Not a X... Not a Y... A Z." | Dramatic buildup through negation |
| "It wasn't X. It wasn't Y. It was Z." | Same structure, past tense |

**Instead:** State Z. The reader doesn't need the runway.

## Dramatic Fragmentation

Sentence fragments for emphasis read as manufactured profundity.

| Pattern | Problem |
|---------|---------|
| "[Noun]. That's it. That's the [thing]." | Performative simplicity |
| "X. And Y. And Z." | Staccato drama |
| "This unlocks something. [Word]." | Artificial revelation |

**Instead:** Complete sentences. Trust content over presentation.

## Rhetorical Setups

These announce insight rather than deliver it.

| Pattern | Problem |
|---------|---------|
| "What if [reframe]?" | Socratic posturing |
| "Here's what I mean:" | Redundant preview |
| "Think about it:" | Condescending prompt |
| "And that's okay." | Unnecessary permission |

**Instead:** Make the point. Let readers draw conclusions.

## Formulaic Constructions

| Pattern | Problem |
|---------|---------|
| "By the time X, I was Y." | Narrative template |
| "X that isn't Y" | Indirect. Say "X is broken" |

## False Agency

Giving inanimate things human verbs. Complaints don't "become" fixes. Bets don't "live or die." Decisions don't "emerge." A person does something to make those things happen. AI loves this because it avoids naming the actor.

| Pattern | Problem |
|---------|---------|
| "a complaint becomes a fix" | The complaint did nothing. Someone fixed it. |
| "a bet lives or dies in days" | Bets don't have lifespans. Someone kills the project or ships it. |
| "the decision emerges" | Decisions don't emerge. Someone decides. |
| "the culture shifts" | Cultures don't shift on their own. People change behavior. |
| "the conversation moves toward" | Conversations don't move. Someone steers. |
| "the data tells us" | Data sits there. Someone reads it and draws a conclusion. |
| "the market rewards" | Markets don't reward. Buyers pay for things. |

**Instead:** Name the actor. "The team fixed it that week" beats "the complaint becomes a fix." Use "you" only when the reader is the actor and the register allows it. When the actor is a system, keep the system as the subject; when the actor is unknown, keep the passive.

## Narrator-from-a-Distance

Floating above the scene instead of putting the reader in it.

| Pattern | Problem |
|---------|---------|
| "Nobody designed this." | Disembodied observation |
| "This happens because..." | Lecturer voice |
| "This is why..." | Same |
| "People tend to..." | Armchair sociologist |

**Instead:** Put the reader in the room when the reader is the actor. "You don't sit down one day and decide to..." beats "Nobody designed this." Do not force "you" into a policy, an API doc, or agent instructions.

## Passive Voice

Every sentence needs a subject doing something. Passive voice hides the actor and drains energy.

The actor is a human or a system, whichever the sentence is actually about. In technical writing the system is often the right subject: "the extension saves an entry" is active and correct, with no human in the sentence. Don't invent a human to satisfy the rule.

Keep the passive when the actor is unknown, irrelevant, omitted on purpose, or
fixed by the document's register.

| Pattern | Fix |
|---------|-----|
| "X was created" | Name who created it |
| "It is believed that" | Name who believes it |
| "Mistakes were made" | Name who made them |
| "The decision was reached" | Name who decided |

**Instead:** Find the actor. Put them at the front of the sentence.

## Sentence Starters to Avoid

| Pattern | Fix |
|---------|-----|
| Wh- openers that only set up a point ("What makes this hard is...", "What if I told you...") | Restructure. Lead with the subject or the verb. |
| Paragraphs starting with "So" | Start with content |
| Sentences starting with "Look," | Remove |

The target is empty setup, not the word. "What makes this hard is..." becomes "The constraint is..." or better, name the specific constraint. A genuine question, a conditional ("When the build fails, check the log"), and a heading all keep their opener.

## Rhythm Patterns

| Pattern | Fix |
|---------|-----|
| Three items chosen for cadence, not content | Cut to the items that carry a fact. Keep all three when all three are true. |
| Questions answered immediately | Let questions breathe or cut them |
| Every paragraph ends punchily | Vary endings |
| Em-dashes in prose | Remove. Use commas or periods. |
| Staccato fragmentation | Don't stack short punchy sentences |
| "Not always. Not perfectly." | Hedging disguised as reassurance |

The em-dash ban covers prose only. A `**Label** — description` separator in a definition list or bullet list is structure, and changing it just to satisfy the rule breaks consistency with the rest of the document.

## Word Patterns

| Pattern | Problem |
|---------|---------|
| Unsupported extremes (every, always, never, everyone, everybody, nobody) | False authority. Use specifics. Keep the word when the claim is literally true. |
| Empty adverbs ("really," "just," "literally," "genuinely," "honestly," "simply," "actually") | Empty emphasis. Keep adverbs that carry a fact, such as `locally` or `asynchronously`. See phrases.md. |
