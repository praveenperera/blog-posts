---
title: "The Missing 153: What I Tried After Reconstructing Coldcard Wave 1"
author: Praveen Perera
tags: bitcoin, security, coldcard, rng, entropy, forensics
description: A complete account of the derivation paths, Coldcard states, pad ranges, dice rolls, and passphrases tested while searching for the 153 unresolved Wave 1 addresses
twitter:
  image: https://praveenperera.com/images/posts/coldcard-wave1-heading.png
  image:width: "3000"
  image:height: "1200"
  image:alt: The missing 153, what I tried after reconstructing Coldcard Wave 1
  card: summary_large_image
---

> **Affected users:** Updating firmware does not repair a seed that affected firmware already generated. Read the [official COLDCARD advisory][2] and replace the affected seed before you use the wallet again. This post explains an investigation. It is not a wallet-recovery guide.

Since I published [*Inside Wave 1*][1], several researchers have asked what I have tried to recover the seeds behind the final 153 addresses. I should have included more of that work in the original post. I summarized the search with a few examples and aggregate numbers, but that summary left out many of the hypotheses, completed searches, and useful negative results.

This post is a supplement to the original Wave 1 reconstruction. It records what I tested, what each search found, and why I stopped.

None of these tests recovered a seed behind the 153. I cannot say that every version of every idea is impossible. Proving that would mean grinding through every combination of device state, wallet path, and entropy input. That would cost a lot more GPU time and money. It would also be hard to reconcile with the simple search that found the rest of Wave 1. I now consider these explanations possible but highly unlikely.

The strongest new evidence concerns passphrases. A scan of all 2,048 lowercase BIP39 words across 1,014 recovered mnemonics found 74 historically funded passphrase addresses holding 32.77836472 BTC immediately before Wave 1. Wave 1 took the empty-passphrase wallets from those same seeds but left every passphrase address untouched. This makes passphrases an unlikely explanation for the missing 153. Something is probably still missing from the way I model the attacker’s seed search.

## What I tried

- [Wider Bitcoin wallet paths](#wider-bitcoin-derivation-paths): I searched higher indexes, change addresses, more accounts, and wrapped SegWit. The searches found affected wallets and reproduced known Wave 1 seeds, but found none of the 153.
- [Other Coldcard setup sequences](#other-coldcard-setup-sequences): I tested settings saves, migration, login-keypad changes, countdowns, erased state, and nine other sequences. They found real affected wallets and known Wave 1 seeds, but none of the 153.
- [Added dice rolls](#added-dice-rolls): One-roll and two-roll searches found historically funded seeds outside Wave 1. A wider partial search also found funded seeds, but no tested dice result belonged to Wave 1.
- [Larger pad ranges](#larger-pad-ranges): I tested higher pad groups and samples from the full 32-bit range. The searches either found nothing or reproduced seeds I already knew. None found one of the 153.
- [Other wallets from recovered seeds](#other-wallets-from-recovered-seeds): I checked wider BIP44, BIP49, and BIP84 paths, BIP85 children, the Coldcard duress path, Samourai paths, Wasabi use, and known weak passphrases. None produced one of the 153.
- [BIP39 passphrases](#why-passphrases-probably-do-not-explain-the-153): I tested every lowercase English BIP39 word on all 1,014 recovered mnemonics. The search found 74 historically funded passphrase addresses, but Wave 1 left all of them untouched.

[The remaining possibilities](#what-remains-open) are listed with the reasons I have not searched every combination and why most are now unlikely.

## The starting point

Wave 1 contains 1,195 traceable source addresses and 1,082.65318922 BTC. Reconstructed seeds explain 1,042 of those addresses and 949.70395260 BTC. The remaining set is:

| Branch       | Unresolved sources |   Unresolved BTC |
| ------------ | -----------------: | ---------------: |
| Original 500 |                 24 |      29.09279145 |
| Holding 2    |                 76 |      36.72277745 |
| Holding 3    |                 53 |      67.13366772 |
| **Wave 1**   |            **153** | **132.94923662** |

Of these sources, 149 use native SegWit and four use wrapped SegWit. Their theft transactions do not look different from the rest of Wave 1. All 153 use the same one-source, one-output format and fee rule. The difference must come before transaction creation: the attacker’s seed search, device state, wallet paths, or choice of targets.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../images/posts/coldcard-missing153-clue-dark.svg">
  <img src="../images/posts/coldcard-missing153-clue-light.svg" alt="Six search families produce no new matches while the same 153 Wave 1 sources remain unresolved">
</picture>

[The public CSV][3] contains the 153 addresses, their script types, Wave 1 branches, sweep heights, input counts, and swept values. Here, “unresolved” means that none of the recovered seeds produced the source address on the paths I tested. The transactions and addresses themselves are not in doubt.

## What a negative result means

I used two types of search. One replayed the weak Coldcard RNG to look for unknown seeds. The other started from recovered seeds and checked related wallets, such as other accounts, BIP85 children, duress wallets, Samourai paths, and passphrase wallets.

The first type can find a new seed, but only within the device states and wallet paths tested. The second cannot find a new root seed, but it shows what the attacker probably checked after finding one. This is why the passphrase result is useful.

## Wider Bitcoin derivation paths

I tested whether the 153 were on common wallet paths but farther from the usual first address. These searches still found affected wallets outside Wave 1 and reproduced known Wave 1 seeds, so the search itself was working. None found one of the 153. A wrong account, branch, or index is now an unlikely general explanation.

The main unknown-seed search models Coldcard 4.0.0+ with its membrane keypad, a zero RTC state, no added dice rolls, and the normal pad range. A keypad count is the number of keypad scan sessions before seed generation. It is usually, but not always, the same as the number of button presses. I completed these wallet paths:

| Address type | Branch         | Accounts | Indexes | Keypad counts |
| ------------ | -------------- | -------: | ------: | ------------: |
| BIP84        | Receive        |        0 |    0–25 |         1–100 |
| BIP84        | Receive        |        0 |  26–100 |          6–52 |
| BIP84        | Receive        |        0 | 101–250 |          8–52 |
| BIP84        | Change         |        0 |   0–100 |          6–52 |
| BIP84        | Receive/change |      1–4 |    0–20 |          6–52 |
| BIP84        | Receive        |      1–4 |   21–60 |          6–52 |
| BIP84        | Change         |      1–4 |   21–50 |  40–48 and 52 |
| BIP84        | Receive/change |     2–25 |    0–20 |          8–24 |
| BIP49        | Receive/change |      0–4 |    0–50 |          8–19 |

I then ran four follow-up searches to fill gaps left by the earlier work:

- Accounts 2–25, both receive and change, indexes 0–20: 100,270,080 possible seeds tested. The search found nine affected seeds and 56 funded addresses, but I already knew all nine seeds. None explained a new Wave 1 source.

- Account 0, receive indexes 26–100 and change indexes 0–100, for keypad counts six and seven: no funded address found.

- Accounts 1–4, receive and change through index 50, for the higher Wave 1 keypad counts: one seed I already knew, outside Wave 1. None of the 153.

- Accounts 1–4, receive indexes 21–60, for the remaining keypad counts from six through 52: 277,217,280 possible seeds tested. The search found four affected seeds I already knew and 28 funded addresses. One was an already-explained Wave 1 source. None was among the 153.

I also ran a smaller search of Samourai’s Bad Bank, Premix, Postmix, and Ricochet account numbers. It checked 17,694,720 possible seeds at native-SegWit receive indexes 0–2 for three common keypad counts. It found no historically funded address.

A small extension of a standard account or index range is now an unlikely general answer. There is no single maximum index because the coverage also depends on the account and keypad count. The deepest account-zero search reached receive index 250 for keypad counts 8–52. The table gives the exact limits for every completed range.

## Other Coldcard setup sequences

The main trace is not the only sequence of RNG calls that affected firmware could produce. Setup operations can consume weak random values before seed generation and move the generator to a different state.

I tested specific sequences involving settings saves, migration, randomized login keypads, countdowns, erased state, and related setup actions. The settings-save and migration searches found three new affected seeds outside Wave 1 and reproduced seeds I already knew. They found none of the 153.

I also tested nine other sequences across 53,084,160 possible seeds. They found eight affected seeds. Four were new and outside Wave 1. Two known Wave 1 seeds reproduced six already-explained source addresses. None matched an unresolved source.

The alternative sequences produced real, historically funded wallets and reproduced known Wave 1 evidence. None crossed into the unresolved set. Substituting one of these tested sequences for the main sequence does not explain the gap.

## Added dice rolls

Here, added dice means a small number of rolls mixed into the normal device-generated seed path. It is different from the documented dice-only process, where enough rolls supply the seed entropy without the weak device RNG.

One complete native-SegWit search tested one and two added rolls for keypad counts 8–50 on account-zero receive indexes 0–25. It found four historically funded seeds outside Wave 1: three with one added roll and one with two. It found no Wave 1 seed.

A second search covered legacy and wrapped-SegWit addresses. It finished 677 of 765 planned batches for one to three added rolls and keypad counts 6–45. It checked 60,595,816,960 possible seeds and found two affected seeds with 29 historically funded addresses, but no Wave 1 source.

The added-roll searches can find real affected wallets, but none of the tested results belongs to Wave 1. Three or more rolls, other wallet paths, other device sequences, and the 88 unfinished batches remain untested.

## Larger pad ranges

The weak RNG used a 32-bit internal value called the pad. The search groups pad values into blocks of 65,536; the research logs call each group number a “high word.” Recovered wallets appear only in groups 15–75, and recovered Wave 1 wallets stop at 74. I tested higher groups and samples from the full pad range.

The complete test of groups 90–99 covered native and wrapped-SegWit account-zero receive indexes 0–25 for keypad counts 8–52. It found nothing.

The complete test of groups 100–255 checked 511,180,800 possible seeds on native-SegWit account-zero receive indexes 0–25 for keypad counts 6–55. It found nothing.

A wider search sampled the full 32-bit pad range. It finished 368 of 3,200 planned batches and tested 24,696,061,952 possible seeds on native and wrapped-SegWit account-zero receive indexes 0–25. It found 35 affected seeds, all of which I already knew. Twenty-two of those seeds reproduced 52 already-explained Wave 1 sources. It found none of the 153.

A separate, evenly spread sample covered 6.25% of the full pad range for each of keypad counts 12, 13, and 16. It tested 805,306,368 possible seeds on native-SegWit receive indexes 0–7 and found nothing.

An earlier test checked all 4,294,967,296 pad values for a different device state with no earlier RNG call. It checked the first receive address on BIP44, BIP49, and BIP84 against 499 theft addresses and found no match. It did not model the later keypad sequence, so it does not rule out that model.

Another researcher reported a wider search of all `2^32` pad values with no match to the 153. I do not yet have enough detail to reproduce it: the device sequence, keypad counts, RTC and dice states, wallet paths, and result files. I treat it as supporting evidence, but I do not include it in my totals.

The pad searches make a simple “the UID or pad range was larger” explanation unlikely.

## Other wallets from recovered seeds

Once I recovered a seed, I checked many more wallet paths than the path that first found it.

For the recovered seeds, I checked BIP44, BIP49, and BIP84 accounts 0–25, both receive and change, through index 2,000. An older set of 949 seeds also covered BIP49 and BIP84 receive accounts 0–999 at indexes 0–20. Neither search produced one of the 153.

I also tested:

- BIP85 child wallets on documented paths;
- the Coldcard Mk3 duress path;
- nine passphrases already observed on affected wallets;
- Samourai Bad Bank, Premix, Postmix, and Ricochet paths through index 2,000; and
- standard Wasabi use, which falls inside the tested BIP84 account-zero path.

None produced one of the 153.

## Why passphrases probably do not explain the 153

Passphrases required a separate test because a BIP39 passphrase creates a different wallet from the same mnemonic. A correct root mnemonic with the wrong passphrase derives unrelated addresses.

A private research corpus shared with me had already found weak passphrases on affected wallets. Those findings made passphrases a real hypothesis, but testing only the observed words could miss another simple passphrase.

I tested every word in the 2,048-word English BIP39 list as a lowercase passphrase on all 1,014 recovered funded mnemonics. For each mnemonic and passphrase, I derived native and wrapped-SegWit account-zero receive indexes 0–26 and checked whether they held bitcoin at block 960182, just before Wave 1.

The test performed 2,076,672 mnemonic-and-passphrase checks and 112,140,288 address checks. It found 74 historically funded native-SegWit addresses on six recovered mnemonics. Those addresses held 32.77836472 BTC before Wave 1.

None of the 74 addresses was in the unresolved set. More important, Wave 1 had already taken empty-passphrase addresses from those same six root mnemonics. The passphrase addresses held bitcoin at the same time, but:

- none was a Wave 1 source;
- none was spent in the Wave 1 blocks 960183–960191;
- none paid a Wave 1 collector; and
- none appears in the later published Galaxy victim lists that I checked.

All 74 addresses were emptied later. Their first post-snapshot spends occurred in these block groups:

| First spend height | Addresses | Timing |
| -----------------: | --------: | ------ |
|             960350 |        12 | About 160 blocks after Wave 1 and next to the published Wave 2 window |
|      960362–960381 |        23 | After Wave 1 |
|             960430 |         7 | After the published Wave 2 window |
|             960450 |        11 | After the published Wave 2 window |
|             960759 |        21 | After the published Wave 3 window |

Those later spends went to unlabeled addresses, not the known Wave 1 collectors or any Galaxy-labeled attacker or victim address. The timing proves that Wave 1 did not take these passphrase UTXOs. It does not prove that the same attacker took them later.

If the attacker had tried one lowercase BIP39 word after recovering each mnemonic, these were the easiest passphrase wallets to find. Funded targets were there. Wave 1 took the empty-passphrase wallets and left the one-word passphrase wallets.

That is strong evidence that Wave 1 used an empty passphrase and that passphrases do not explain the 153 as a group.

This does not rule out every possible passphrase. I did not test two-word or three-word phrases, case variants, arbitrary strings, nonstandard paths, or wallets whose root mnemonic remains unknown. Testing every variation would cost far more than the evidence justifies.

I also started a much larger search that combined unknown Coldcard seeds with all 2,048 one-word passphrases. It had 4,140 planned batches. I stopped after 11 because checking 52 wallet paths made the search too expensive for the value of the result. Those 11 batches tested 1,476,395,008 seed-and-passphrase combinations and found no funded seed. I do not count the other 4,129 batches because they never ran.

The recovered-seed check tells us much more. Easy, funded passphrase wallets existed on seeds that Wave 1 had already reached, and Wave 1 did not take them.

## The address list was not the problem

For each possible seed, the search generated Bitcoin addresses and checked them against a snapshot of funded addresses from block 960182, immediately before Wave 1. The snapshot contains 23,221,718 native-SegWit addresses, 21,242,700 legacy addresses, and 6,238,520 wrapped-SegWit addresses.

I checked that all 153 unresolved addresses were in the snapshot. If a tested seed had produced one of them on a tested path, the search would have reported a match.

## What remains open

These are not equally likely, and most do not have a natural endpoint.

<div id="open-searches-table"></div>

| What remains open | Why it is not a leading explanation | Why I have not searched all of it |
| ----------------- | ----------------------------------- | --------------------------------- |
| Native-SegWit account 0 beyond receive index 250 or change index 100 | The highest recovered Wave 1 match is at receive index 234; the highest change match is at index 65. Extending the recovered seeds through index 999 found no later match, and the wider check through index 2,000 found none of the 153. | Every added index must be checked across millions of possible seeds. I stopped after the searches went past the last indexes that had produced a Wave 1 match. |
| Wider native-SegWit paths on other accounts | Wider paths did find earlier Wave 1 seeds, but the later extensions kept reproducing known seeds or finding wallets outside Wave 1. They stopped adding addresses from the final 153. | Each added account, index, and keypad count multiplies the work. The completed ranges are in the table above. |
| Wrapped-SegWit accounts above 4, indexes above 50, or keypad counts outside 8–19 | Only four of the 153 sources use wrapped SegWit, so this cannot explain the other 149. The tested wrapped-SegWit extensions found no member of the final group. | A wider search repeats the full seed search for each new path. |
| More Coldcard setup sequences combined with wider wallet paths | The tested settings, migration, login-keypad, countdown, erased-state, and nine other sequences found real affected wallets and reproduced known Wave 1 seeds. None found one of the 153. | Each setup sequence needs a source-based model. Combining every plausible sequence with every path would create a very large search, including many device states that may never occur. |
| More values from the full 32-bit pad range | The completed higher ranges found nothing. A 24.7-billion-seed sample of the full range found only known seeds, and a separate 6.25% sample found nothing. Another researcher has also reported a wider zero result. | Testing all `2^32` pad values again for every keypad count and wallet path would require hundreds of billions of additional seed checks. |
| A nonzero real-time-clock state | The firmware disables the relevant RTC and hardware-RNG paths, device evidence supports a zero RTC state, and no recovered Wave 1 seed requires a nonzero value. | An arbitrary clock value adds another large input range with no evidence-based bound. |
| Three or more added dice rolls or other entropy combinations | Every recovered Wave 1 seed uses zero added rolls. The native-SegWit search found four historically funded seeds with one or two added rolls, all outside Wave 1. The finished part of the wider dice search also found funded seeds, but none in Wave 1. | Each roll multiplies the possible inputs by six, before wallet paths and device states are added. |
| Another affected firmware release or Coldcard device model | The current model explains 1,042 Wave 1 sources across all three branches. Other tested device sequences found affected wallets but did not enter the unresolved set. | Each one needs its own source review, device sequence, and seed generator before it can be searched. There is no specific alternative to test yet. |
| Two-word and longer passphrases, case variants, or arbitrary strings | The attacker left 74 easy, funded one-word passphrase addresses untouched while taking empty-passphrase wallets from the same seeds. It is unlikely that the attacker skipped those and found a separate group of harder passphrases. | I tested the complete one-word list first. The two-word search is next but has not run yet; it requires about 4.25 billion PBKDF2 checks. Three words require about 8.7 trillion, and arbitrary strings have no limit. |
| An imported seed or another seed-generation method | A securely generated imported seed is not exposed by the Coldcard RNG flaw. This would require a second way for the attacker to learn the seeds, and I have no evidence of one. | There is no finite search until another weak generator, leak, or source of seed data is identified. |
| An input or search method that the reconstruction does not model | This is the exception: I think it is now the leading possibility. The tested methods keep finding real affected wallets, but all stop at the same 153 before transaction creation. | I cannot search it until I can identify the missing input or turn the method into a concrete candidate generator. |

The searches do not support Taproot, multisig, or a legacy-only explanation for the 153 because the sources themselves are 149 native-SegWit and four wrapped-SegWit single-key addresses. Multisig or Taproot activity elsewhere cannot directly produce these source scripts.

## What the failures suggest

The final 153 do not look like a random collection of paths that the search barely missed. Their missing rate changes sharply by Wave 1 branch: 4.80% in Original 500, 15.48% in Holding 2, and 25.98% in Holding 3. At the same time, all three groups use the same theft transaction builder.

Each method can find real affected wallets. Wider paths and other Coldcard sequences found real seeds. Added-dice searches found real seeds. The full-pad sample reproduced known Wave 1 seeds. The one-word passphrase search found real funded wallets. Yet every method stopped at the same 153.

This makes simple wallet-path, dice, passphrase, and pad-range explanations unlikely. I think the search still lacks an input, initial state, device sequence, or other method that the attacker used before creating the theft transactions.

The 153 remain unresolved. I will update this post as I try more paths.

[1]: /blog/coldcard-mk3-weak-rng-wave1/
[2]: https://coldcard.com/docs/upgrade/#important-security-advisory
[3]: /data/posts/coldcard-wave1-unresolved-153.csv
