==title==
A New Approach to Universal Bitcoin Wallet Backup with Passkeys and PRF

==author==
Praveen Perera

==tags==
bitcoin, security, passkeys, webauthn, prf, cove

==description==
A proposal for cross-platform Bitcoin wallet backup using WebAuthn PRF, no passwords, no server trust

==updated_at==
2025-12-16

==body==
I've been building [Cove](https://covebitcoinwallet.com), a Bitcoin wallet focused on making self-custody accessible. We launched with the standard approach: show users their 12/24 words, tell them to write it down somewhere safe. But Cove is supposed to be beginner-friendly, and for users just getting started with a hot wallet, keeping those words secure and not losing them is a major source of anxiety.

I've wanted to add automatic cloud backup for a while, but I hadn't found a solution I loved. After researching existing approaches and working through the tradeoffs, I designed an architecture using the WebAuthn PRF (Pseudo-Random Function) extension combined with untrusted cloud storage. PRF lets us derive an encryption key from a passkey, so we can store encrypted data in iCloud or Google Drive without having to trust Apple or Google. This post outlines a proposal for a universal backup mechanism that any wallet can implement.

I'm working with [Tankred Hase](https://x.com/tankredhase) to develop this into a proper specification. I'm building this for Cove, and Tankred is interested in implementing it in [StashPay](https://stashpay.me/). The goal is to prove the concept works across different wallets and platforms before formalizing the spec.

## Table of Contents

- [Existing Cloud Backup Solutions](#existing-cloud-backup-solutions) - Phoenix, Kraken, Bull Bitcoin
- [Why Not iCloud Keychain Directly?](#why-not-icloud-keychain-directly) - The verification problem
- [Enter WebAuthn PRF](#enter-webauthn-prf) - How PRF works
- [The Architecture](#the-architecture) - Setup and restore flow
- [Platform Support](#platform-support) - iOS 18.4+, Android 9+
- [Proposed Implementation](#proposed-implementation) - Data structures and formats
- [Security Considerations](#security-considerations) - Caveats and risks
- [What's Next](#whats-next) - Formal specification
- [Feedback](#feedback) - Get in touch

## Existing Cloud Backup Solutions {: #existing-cloud-backup-solutions}

Before starting work on Cove's backup, I looked at a few existing iCloud backup implementations.

### Phoenix Wallet

[Phoenix](https://phoenix.acinq.co/) was the first wallet where I really liked the backup UX. Automatic, invisible, just works.

Looking into their implementation, they use [CloudKit](https://developer.apple.com/icloud/cloudkit/) with `encryptedValues`<sup>[[1]]</sup>. The problem is that CloudKit is not end-to-end encrypted by default<sup>[[2]]</sup>. It requires the user to enable [Advanced Data Protection](https://support.apple.com/en-us/102651) (ADP), which most users don't know about. Without ADP, Apple can technically access the data.

I like that Phoenix includes a disclaimer explaining this to users. And honestly, this is probably an acceptable trade-off for most people using a hot wallet, Apple rugging you isn't in most people's threat models. But I wanted to see if there was something better.

### Kraken Wallet

[Kraken Wallet](https://www.kraken.com/wallet) took a different approach using passkeys. What I liked was that it's a fully end-to-end encrypted solution. They use the WebAuthn `largeBlob` extension to store the encrypted seed directly inside the passkey.

But looking deeper, I found some limitations:

- **iOS only** - Android doesn't support largeBlob<sup>[[3]]</sup><sup>[[13]]</sup>
- **Single seed** - They store a single master seed and derive multiple accounts using standard BIP32 paths, which means you can't backup imported wallets
- **iCloud Keychain only** - When I tried it, it didn't work because I use 1Password. To get Kraken's passkey backup working, I would have had to disable 1Password as my global password manager. PRF, on the other hand, is supported by third-party password managers including [1Password](https://1password.com/blog/encrypt-data-saved-passkeys) and [Bitwarden](https://bitwarden.com/blog/prf-webauthn-and-its-role-in-passkeys/).

More fundamentally, Kraken's approach stores the encrypted seed _inside_ the passkey credential itself using largeBlob. The approach I'm proposing uses the passkey only to derive an encryption key; the encrypted data lives separately in cloud storage. This decoupled architecture removes the size limitations and enables Android support.

### Bull Bitcoin (Recoverbull)

While I was working on this, Bull Bitcoin released [Recoverbull](https://www.bullbitcoin.com/blog/recoverbull-a-bitcoin-wallet-backup-system), based on the Photon spec with a key server. I thought it was elegant, but I didn't want to go with it because of the requirement to run a key server. I didn't want to be responsible for maintaining that infrastructure.

All of these made smart tradeoffs for their use cases. But I wanted something cross-platform, no server to maintain, and supports arbitrary wallet imports.

## Why Not iCloud Keychain Directly? {: #why-not-icloud-keychain-directly}

While looking into Phoenix and Kraken, I noticed that Kraken was using iCloud Keychain for their passkeys. That's when I started wondering, why aren't people just using iCloud Keychain directly? Store the seed with `kSecAttrSynchronizable = true`, let Apple sync it. Done.

This is where Tankred Hase comes in. Tankred created [Photon SDK](https://github.com/photon-sdk/photon-lib), an open-source library for seedless wallet backups (which Recoverbull is based on), so I reached out to get his perspective on my approach.

He pointed out a critical flaw, there's no API to verify if a Keychain item actually synced to iCloud. A user could have iCloud Keychain disabled, or syncing could fail silently. They'd think their wallet is backed up when it isn't. That's how people lose Bitcoin.

I had initially planned to use iCloud Keychain on iOS and Google Block Store on Android. I already knew Google Block Store had no verification API (you can't tell if the user has backup enabled). Tankred pointed out iCloud Keychain has the same problem. That explained why people weren't just using iCloud Keychain directly.

I told Tankred I was already thinking about using PRF for Android since it works with Google Password Manager. Maybe I could just use PRF for both iOS and Android? Passkeys solve the verification problem because they're always synced through the platform's password manager by design, not device-specific like Keychain items.

## Enter WebAuthn PRF {: #enter-webauthn-prf}

The [PRF extension](https://w3c.github.io/webauthn/#prf-extension) is a relatively new addition to WebAuthn. It lets you derive a deterministic 32-byte secret from a passkey authentication.

Here's what makes it interesting:

- **Deterministic** - `PRF(passkey, salt)` always produces the same output
- **Requires authentication** - User must complete biometric/PIN each time
- **Hardware-backed** - The PRF secret never leaves the secure element
- **Phishing-resistant** - Bound to the relying party origin

The output is essentially [`HMAC-SHA256(device_secret, salt)`](https://developers.yubico.com/WebAuthn/Concepts/PRF_Extension/CTAP2_HMAC_Secret_Deep_Dive.html). You get a cryptographically strong 32-byte key that's reproducible, protected by biometrics, and never transmitted over the network.

To my knowledge, this is the first proposed specification for cross-platform Bitcoin wallet backup using PRF.

## The Architecture {: #the-architecture}

Cloud backup is designed as a separate layer. Users start with a local master key and can enable cloud backup later.

![Architecture diagram showing local setup, cloud backup, and restore flows](/images/posts/passkey-prf-architecture.png)

```text
LOCAL SETUP (no cloud):

1. First wallet creation generates random 32-byte master key
2. Master key stored in local secure storage (Keychain/Keystore)
3. Derive critical_data_key = HKDF(master_key, "cspp:v1:critical")
4. Encrypt seed with critical_data_key
5. (Optional) Derive sensitive_data_key = HKDF(master_key, "cspp:v1:sensitive")
6. (Optional) Encrypt xpubs, wallet database, labels with sensitive_data_key
7. User has no cloud backup - just their seed words

ENABLE CLOUD BACKUP:

1. User creates passkey for your wallet's backup domain
2. App generates random 32-byte salt
3. PRF(passkey, salt) → prf_key
4. Encrypt master_key with prf_key
5. Upload encrypted master key + per-wallet backups to cloud

RESTORE ON NEW DEVICE:

1. Fetch encrypted master key backup and wallet backups from cloud storage
2. User authenticates with synced passkey
3. PRF(passkey, salt) → prf_key
4. Decrypt master_key
5. Derive critical_data_key, decrypt all wallet seeds
```

The key design decision is **decoupled storage**. The PRF protects the master key, but we store encrypted data separately in the user's own cloud storage (iCloud CloudKit on iOS, Google Drive appDataFolder on Android).

This means:

- No wallet servers ever see your data
- Users can verify their passkey exists in Settings → Passwords
- No size limitations (unlike WebAuthn's largeBlob extension)
- Cloud backup is opt-in, not required

Each wallet is encrypted separately with its own nonce. Granular restore, independent wallet management, no single point of failure.

## Platform Support {: #platform-support}

PRF is available on:

- **iOS 18.4+ / macOS 15.4+** (iCloud Keychain passkeys) - minimum supported version
- **Android 9+** (Google Password Manager)

The passkey syncs across devices through the platform's password manager. Same encryption key everywhere.

**Warning: iOS 18.0-18.3 is not supported.** Apple announced PRF support<sup>[[4]]</sup> at WWDC 2024, but iOS 18.0-18.3 had a bug in Cross-Device Authentication (CDA) where PRF outputs varied depending on authentication method<sup>[[5]]</sup><sup>[[12]]</sup>, which could cause data loss for encrypted data. Users on iOS 18.0-18.3 must upgrade to iOS 18.4 or later before relying on PRF-based backups. Wallet implementations should check the iOS version and refuse to enable PRF backup on affected versions.

This also explains why older wallets weren't using this approach. It only became viable recently. Before iOS 18.4, the only cross-platform option would have been largeBlob on iOS (introduced in iOS 17) and PRF on Android, requiring two different implementations. iOS 18.4 was released on March 31, 2025<sup>[[6]]</sup>. Now PRF works reliably on both platforms.

## Proposed Implementation {: #proposed-implementation}

This section outlines my proposed technical details, which will serve as the basis for the formal specification. I'm tentatively calling it **CSPP** (Cove StashPay Passkey Protocol), though the name will probably change. These details are subject to change as we validate with real implementations.

Cloud backup is opt-in. Users can start with local-only storage and enable or disable cloud backup later. This flexibility doesn't complicate the wallet's logic because the master key lives locally, independent of the passkey.

### Key Hierarchy

```text
MASTER KEY (32 bytes, random, generated on first wallet creation)
│
├── Stored locally (never synced):
│   • iOS: Keychain with kSecAttrSynchronizable = false
│   • Android: Android Keystore (hardware-backed)
│
├── CRITICAL DATA KEY = HKDF(master_key, "cspp:v1:critical")
│   └── For encrypting ALL seeds (single key for all wallets)
│
└── SENSITIVE DATA KEY = HKDF(master_key, "cspp:v1:sensitive")
    └── For encrypting ALL xpubs (single key for all xpubs)
```

We use a single key for all wallets rather than per-wallet derivation, trading some defense-in-depth for simplicity. ChaCha20-Poly1305 is secure as long as nonces aren't reused, and random 12-byte nonces make that effectively guaranteed. Implementations that prefer stronger compartmentalization can derive per-wallet keys using `HKDF(master_key, "cspp:v1:critical:" || wallet_id)`.

When the user enables cloud backup, the master key is encrypted with the PRF-derived key and uploaded.

### Data Structures

Two types of records are stored in the cloud. The Rust structs below illustrate the logical structure, but wire format and versioning will be defined in the formal spec.

**Master Key Backup** (one per user):

```rust
pub struct EncryptedMasterKeyBackup {
    pub version: u32,              // format version (1)
    pub salt: [u8; 32],            // PRF salt (random, per-user)
    pub nonce: [u8; 12],           // ChaCha20 nonce
    pub ciphertext: Vec<u8>,       // encrypted master_key (32 bytes + auth tag)
}
```

This design assumes one passkey per user for the backup domain. Credential ID storage (for disambiguating multiple passkeys) will be addressed in the formal specification; for now, platform APIs handle credential lookup through `preferImmediatelyAvailableCredentials` on iOS and `getCredential()` on Android.

**Wallet Backup** (one per wallet):

```rust
// Stored in cloud (unencrypted fields + encrypted payload)
pub struct EncryptedWalletBackup {
    pub version: u32,              // format version (1)
    pub wallet_id: String,         // app-level unique ID (e.g., UUID)
    pub nonce: [u8; 12],           // ChaCha20 nonce
    pub ciphertext: Vec<u8>,       // encrypted WalletEntry (below)
}

// Plaintext payload (encrypted inside ciphertext)
pub struct WalletEntry {
    pub wallet_id: String,                 // app-level unique ID (e.g., UUID)
    pub secret: WalletSecret,              // Mnemonic | Descriptor | WatchOnly
    pub network: Network,                  // mainnet | testnet | signet
    pub name: Option<String>,              // user-facing wallet name
    pub master_fingerprint: Option<[u8; 4]>, // BIP32 master fingerprint
    pub derivation_path: Option<String>,   // e.g., "m/84'/0'/0'"
    pub extra: Option<Map<String, Value>>, // app-specific fields
}

pub enum WalletSecret {
    Mnemonic(String),
    Descriptor(String),
    WatchOnly,
}
```

The `extra` field allows wallet developers to store app-specific metadata. This backup is primarily for seeds and is typically created once when the wallet is generated. Keep it to the minimum metadata needed for restoration.

### Encryption

**Algorithm**: [ChaCha20-Poly1305](https://datatracker.ietf.org/doc/html/rfc8439) (AEAD)

We chose ChaCha20-Poly1305 over AES-GCM for several reasons:

- **Native mobile support** - Built into iOS (CryptoKit) and Android (javax.crypto) with no external dependencies
- **Software performance** - ChaCha20 is designed to be fast in pure software. While modern phones have AES hardware acceleration, ChaCha20 performs well even on older or budget devices without it
- **Constant-time by design** - Uses only add-rotate-xor operations, making it naturally resistant to timing side-channel attacks without special implementation care
- **Widely deployed** - Used in TLS 1.3, WireGuard, and Signal Protocol

**PRF → Master Key Encryption**: The PRF output is used directly as the encryption key for the master key backup. No HKDF needed - the PRF output is already uniformly pseudorandom (it's HMAC output), and [RFC 5869](https://www.rfc-editor.org/rfc/rfc5869#section-3.3) explicitly allows skipping the extract step for such inputs.

**Master Key → Derived Keys**: We use HKDF-SHA256 with info strings `"cspp:v1:critical"` and `"cspp:v1:sensitive"` for domain separation.

### Cloud Storage

| Platform    | Storage                     | Notes                |
| ----------- | --------------------------- | -------------------- |
| **iOS**     | CloudKit (private database) | Hidden from user     |
| **Android** | Google Drive appDataFolder  | Hidden from Drive UI |

Both are "hidden" storage - users can't accidentally browse to it and delete it. But since the data is encrypted, any storage works. Implementers can choose their own storage backend.

### Passkey Rotation

One advantage of the master key architecture: if the user accidentally deletes their passkey, recovery is simple:

1. App detects passkey is missing (but master key exists locally)
2. Create new passkey
3. Generate new salt
4. Encrypt local master key with new PRF-derived key
5. Upload new `EncryptedMasterKeyBackup`

Only one cloud record changes. Per-wallet backups stay the same because they're encrypted with keys derived from the master key, not the passkey.

### Backup Verification

**iOS**: Using `preferImmediatelyAvailableCredentials`<sup>[[7]]</sup>, the app can silently detect if a passkey is missing - if no matching credentials exist, the request fails immediately without showing any UI<sup>[[8]]</sup>. This allows the app to detect a deleted passkey on startup without interrupting the user. However, actually verifying backup integrity (which requires a PRF operation to decrypt data) still requires biometric authentication.

**Android**: Requires user interaction to verify the passkey. Credential Manager's `getCredential()` shows a bottom sheet UI<sup>[[9]]</sup>, and passkey operations require biometric or PIN verification<sup>[[10]]</sup>. We can turn this into a feature similar to Signal's periodic PIN verification - a "Check Backup" button that prompts biometric auth and verifies all backups are intact. This reinforces backup awareness rather than hiding it.

### Domain Binding

The passkey's relying party should be a dedicated subdomain (e.g., `backup.yourwallet.app`), not the main app domain. This follows Trail of Bits' recommendation<sup>[[11]]</sup> from their Kraken Wallet audit. If the main domain is compromised, a dedicated backup domain limits the blast radius.

This requires setting up domain association files:

- iOS: `/.well-known/apple-app-site-association`
- Android: `/.well-known/assetlinks.json`

## Security Considerations {: #security-considerations}

### What This Protects Against

**Cloud provider access** - Apple and Google only ever see encrypted blobs. Even if they wanted to, they cannot decrypt your seeds without your passkey. This is true regardless of whether Advanced Data Protection is enabled.

**Cloud storage breach** - If an attacker compromises iCloud or Google Drive, they get ciphertext encrypted with ChaCha20-Poly1305. Without the PRF-derived key (which requires biometric auth on your device), the data is useless.

**Phishing attacks** - The passkey is bound to your wallet's relying party domain. A phishing site on a different domain cannot trigger the PRF derivation, even if it looks identical to your wallet.

**Server compromise** - There is no server. Your encrypted data lives in your own cloud storage. There's no central target for attackers.

### What This Doesn't Protect Against

**Device compromise with unlocked passkey** - If malware has access to your device while it's unlocked and can trigger biometric auth (or the user approves a malicious prompt), the attacker could potentially derive the encryption key. This is the same threat model as any passkey-protected system.

**Passkey provider compromise** - If Apple or Google's passkey sync infrastructure is compromised at a fundamental level, an attacker could theoretically access your PRF secret. This is an extreme scenario that would affect all passkey users globally.

**User error** - If a user deletes their passkey AND loses all devices with the local master key, recovery is impossible without offline backups. Wallets should prominently warn users about this.

### Passkey Deletion Recovery

If the user accidentally deletes their passkey but still has a device with the master key locally, recovery is straightforward:

1. App detects passkey is missing
2. Create new passkey
3. Generate new salt
4. Re-encrypt master key with new PRF-derived key
5. Upload new backup

The user's wallet data is never at risk as long as one device retains the local master key.

### Recommended Mitigations

**Seed word backup** - For users who want extra safety, wallets can offer the option to write down their BIP39 seed phrase. This also helps users get familiar with seed words for when they eventually move to hardware wallets, where writing them down is required.

**Passkey status detection** - As mentioned in the Backup Verification section, iOS can silently detect a missing passkey using `preferImmediatelyAvailableCredentials`. Android requires user interaction for any passkey operation. The exact UX patterns for detecting deleted passkeys will likely be addressed in the formal specification.

**Offline recovery kit** - An offline backup of the master key (encrypted with a user-chosen PIN and encoded as a printable format) could provide recovery even if both the passkey and all devices are lost. This is outside the scope of the current proposal but may be explored in a future version of the spec.

## What's Next {: #whats-next}

Tankred and I plan to develop this into a formal specification. We'll be building implementations in Cove and StashPay to validate the approach before finalizing. The goal is a standard that any Bitcoin wallet can adopt, and if it gains traction, we may formalize it as a BIP.

## Feedback {: #feedback}

This is an early proposal, and details will evolve as we develop the formal specification with real-world implementations. I'd love to hear from wallet developers, security researchers, and anyone thinking about this problem. What am I missing? What concerns do you have? Leave a comment below or reach out on [X](https://x.com/praveenperera). Interested in helping shape the spec? Reach out to [Tankred](https://x.com/tankredhase) or me.

[1]: https://github.com/ACINQ/phoenix/blob/f3a227624c2ab262351a5261a5e4a1c6bdfc4887/phoenix-ios/phoenix-ios/sync/SyncSeedManager.swift
[2]: https://support.apple.com/guide/security/cloudkit-end-to-end-encryption-sec3cac31735/1/web/1
[3]: https://www.corbado.com/blog/passkeys-prf-webauthn
[4]: https://webkit.org/blog/15443/news-from-wwdc24-webkit-in-safari-18-beta/
[5]: https://www.corbado.com/blog/passkeys-prf-webauthn
[6]: https://support.apple.com/en-us/122371
[7]: https://developer.apple.com/documentation/authenticationservices/asauthorizationcontroller/requestoptions/preferimmediatelyavailablecredentials
[8]: https://developer.apple.com/forums/thread/737010
[9]: https://developer.android.com/identity/sign-in/credential-manager
[10]: https://developer.android.com/identity/passkeys
[11]: https://github.com/trailofbits/publications/blob/master/reviews/2024-09-kraken-mobile-wallet-icloud-backup-securityreview.pdf
[12]: https://developer.apple.com/forums/thread/764730
[13]: https://groups.google.com/a/chromium.org/g/blink-dev/c/guUJ9FuOIfc
