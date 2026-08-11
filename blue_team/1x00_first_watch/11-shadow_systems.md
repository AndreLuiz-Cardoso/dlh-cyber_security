# Shadow IT Assessment

## Shadow System 1: Dr. Patel's Personal NAS (Cardiology)

**Risk Assessment:**
- Sensitive data potentially present: Cardiology research data, which may include patient-derived clinical data depending on the nature of the research — potentially Restricted-classification information stored entirely outside IT's visibility.
- Controls from the official matrix (Task 10) that do NOT cover it: No firewall rule is scoped to it, no antivirus coverage, no backup process, no access logging — it is invisible to every control in the registry because IT does not know it exists.
- Worst-case scenario: The NAS has a known, unpatched vulnerability (consumer NAS devices are frequent targets for opportunistic scanning and ransomware), is compromised, and either exfiltrates research/patient-derived data or serves as a pivot point into the Cardiology office's network segment — with zero detection, since nothing is monitoring it.

**Recommended Response: Legitimize and Secure.** The device serves a real, articulated business need (research data storage the shared drive doesn't adequately meet), so removing it outright (Decommission) would recreate the underlying problem, and migrating research data to an approved system (Migrate) is the eventual goal but requires first understanding what data is on it. The immediate step is bringing it under IT governance — inventory its contents, apply network isolation and backup, and set a timeline to migrate its function to an approved, IT-managed storage solution.

## Shadow System 2: Marketing's Shared Google Drive (Personal Gmail)

**Risk Assessment:**
- Sensitive data potentially present: Media files and press communications are lower sensitivity than PHI, but the account is tied to a personal Gmail with unknown security posture (password strength, MFA status, personal device access) entirely outside MedDefense's control.
- Controls from the official matrix that do NOT cover it: Corporate password policy (C-003) does not apply to a personal account; no organizational MFA, DLP, or offboarding process governs it — if the employee who owns that Gmail account leaves, MedDefense has no mechanism to revoke access to organizational files.
- Worst-case scenario: The personal Gmail account is compromised (credential stuffing, phishing) and organizational press materials or pre-release communications are leaked or altered before an official announcement, or access persists indefinitely after the owning employee's departure.

**Recommended Response: Migrate.** This is the clearest Migrate case in the set: the data itself (media files, press communications) is not highly sensitive, and a straightforward move to an approved, organization-owned cloud storage account (with proper offboarding and access control tied to the employee's corporate identity) fully resolves the risk without needing new infrastructure.

## Shadow System 3: Raspberry Pi (2nd Floor, Central)

**Risk Assessment:**
- Sensitive data potentially present: Unknown — if it was configured as a network monitor as intended, it may have had access to network traffic or credentials at the time of setup; its current state and any data it holds are unconfirmed.
- Controls from the official matrix that do NOT cover it: None — it predates or sits entirely outside every control in the registry, has had no maintenance, patching, or ownership since both the intern and Marcus left, and its exact network position is unknown.
- Worst-case scenario: An unmaintained device with no patching for months, potentially still holding network-monitoring access or credentials, is compromised and used as a quiet, long-lived foothold — arguably the most dangerous of the three, precisely because nobody is even thinking about it.

**Recommended Response: Decommission.** Unlike the other two, this system currently serves no active business function — its intended purpose (network monitoring) was never formalized and its original owners are gone. The safest action is to physically locate it, confirm its current state and any data/credentials it holds, and remove it from the network entirely. If a real need for network monitoring exists, it should be re-implemented as a properly owned, patched, and IT-governed tool — not revived from an orphaned device.

## Shadow IT Policy Recommendation

The single most effective policy change would be **requiring IT/Security sign-off before any device or cloud service is connected to the corporate network or used to store organizational data** — paired with a simple, fast-turnaround request process so staff have a legitimate, low-friction path to get tools they need (like Dr. Patel's storage need) approved quickly, rather than defaulting to personal solutions out of convenience. All three shadow systems here emerged from a genuine unmet need combined with the path of least resistance being to just plug something in; a policy without a fast approval path would likely just push the same behavior further underground.
