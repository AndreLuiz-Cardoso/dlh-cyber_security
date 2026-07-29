# Root Cause Analysis — `billing-srv-01` Performance Degradation

## 1. Process Identification

The `top` output shows a process labeled `kworker` (disguised to blend in with the legitimate Linux kernel worker thread naming convention) consuming 94.2% CPU under the `www-data` user — the same low-privilege account the web server (`apache2`) runs as. This is not a genuine kernel worker; genuine `kworker` threads run as `root`/kernel-owned and do not appear with a command-line argument pointing to an external host.

The command line includes `-o stratum+tcp://pool.monero.org:4443`. The `stratum` protocol is the standard protocol used by cryptocurrency mining software to connect to a mining pool and receive work assignments. `pool.monero.org` is a public mining pool for Monero (XMR), a privacy-focused cryptocurrency favored in illicit mining operations because its transactions are difficult to trace. The `netstat` output corroborates this: an established connection from the server to `185.243.115.89:4443` (the resolved pool address) plus a second established connection to an unrelated external IP on port 8080, suggesting either a second C2/relay channel or a mining proxy.

**Purpose of this process:** an unauthorized cryptomining payload has been installed on `billing-srv-01` under the web server's service account, using the server's CPU cycles to mine Monero on the attacker's behalf. This is a classic post-compromise monetization technique: once an attacker has code execution on a server (commonly via a web application vulnerability), a low-effort, low-noise way to extract value is to deploy a miner rather than immediately exfiltrate data or deploy ransomware.

## 2. The Real Compromise: Two Pillars Before Availability

The visible symptom — CPU saturation slowing down billing operations — is an **Availability** side-effect. But two more serious violations occurred first and are the actual root cause:

- **Integrity.** For a cryptominer to run as `www-data` and persist across at least three "performance degradation" cycles and a full server rebuild pattern, an attacker had to gain unauthorized code execution and modify the server's file system or startup configuration (e.g., a cron job, a web shell, or a malicious script placed via the same vulnerable web application). This is an authorized-only party's system being altered without authorization — a direct Integrity violation, and it happened *before* any performance was affected.
- **Confidentiality.** A process capable of executing arbitrary code as the web server's user, on a server that hosts billing and insurance claims data, has the technical capability to read, copy, or exfiltrate that data. There is no evidence data was *not* accessed; the absence of a confirmed breach report only means no one has looked. The attacker's demonstrated foothold is sufficient access to breach Confidentiality regardless of whether the miner itself was the only payload deployed.

Only after unauthorized access (Confidentiality risk) and unauthorized modification (Integrity violation) had already occurred did the resulting resource exhaustion manifest as an Availability symptom — CPU saturation. Availability is the last domino, not the first.

## 3. Why the Sysadmin's Hardware Upgrade Fails

Upgrading the server's hardware does not remove the attacker's foothold. If the underlying vulnerability that allowed code execution (most plausibly a flaw in the web application stack running under `www-data`, similar in class to the access-control flaw already found in the patient portal) is not identified and closed, the miner — or any other payload — simply persists on the new hardware, potentially consuming a smaller *percentage* of the larger CPU capacity, making it *harder* to detect through the same symptom (high CPU%) that flagged it in the first place. A hardware upgrade treats the visible symptom (performance) while leaving the actual problem (an active, unauthorized foothold with code execution on a server holding financial and possibly patient billing data) completely intact. It also wastes budget that should go toward incident response and vulnerability remediation.

## 4. Connection to the January Ransomware Incident

The same server suffered a full ransomware encryption event in January and, following rebuild, now shows an independent unauthorized cryptomining foothold. Two unrelated-looking compromises on the same asset within months of each other strongly suggests a **structural weakness in the server or its surrounding controls**, not two unlucky coincidences. Two explanations are most likely, and both point to the same gap: the rebuild after the ransomware incident restored the *same* underlying vulnerability (e.g., the same unpatched application, the same exposed service, the same missing detective controls), so the attacker — or a different opportunistic attacker — walked back in through the same door.

**The question this analyst should be asking:** *What was the actual initial access vector for the January ransomware, and was that vector remediated during the rebuild, or was the server simply restored to its prior configuration?* Given that no monitoring flagged either the ransomware's initial foothold or weeks of an actively-mining process, a second question follows directly: *does MedDefense have any detective control on this server at all* — because right now, the only detection mechanism that has worked twice is a human noticing the server "feels slow."
