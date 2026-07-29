# Control Inventory — MedDefense Health Systems

> **Sourcing note.** The dedicated `meddefense-controls-artifacts.txt` (raw firewall rule sets and the staff-training completion records) was never made available. This inventory is therefore reconstructed from the sources that *were* provided in the onboarding documentation package — the IT service contracts summary, Marcus Webb's `security_observations.txt`, the network diagram, the IT asset export, and the org chart — each of which independently evidences the same control categories the missing artifact would have contained (firewall, password policy, backup, antivirus, physical guard, SSH configuration, VPN). Every control below cites the specific source line it was derived from. The only two items that remain genuinely unconfirmed are (a) the exact firewall rule set and (b) the actual training-program content and completion rates; both are flagged inline rather than assumed.

## Control Registry

**C-001 — FortiGate 100F Perimeter Firewall**
Description: The organization's only firewall, at the Central network edge, terminating the DMZ (`web-srv-01`) and both site-to-site VPN tunnels (Westside, Corporate HQ).
Category: Technical | Function: Preventive
Asset(s) Protected: All Central-hosted servers/applications; Westside/HQ traffic routed through it
Effectiveness: Adequate — it exists and terminates the perimeter, but did not prevent Incident A or the crypto-miner, both of which originated *inside* the flat network where the firewall gives no protection.
Source: Network diagram (`FortiGate 100F` at the edge); IT service contracts (Fortinet support, $4,200/yr)

**C-002 — Corporate Password Policy**
Description: Minimum 8-character passwords, 90-day rotation, complexity enabled, organization-wide.
Category: Administrative | Function: Preventive
Asset(s) Protected: All user accounts across all systems
Effectiveness: Weak — Marcus's own assessment was "not terrible but not great," and it is paired with no MFA anywhere except one account (see C-012), so a single stolen password is sufficient for access.
Source: Marcus Webb's `security_observations.txt` (Authentication section)

**C-003 — Sophos Endpoint Antivirus**
Description: Endpoint protection under an active vendor contract.
Category: Technical | Function: Preventive
Asset(s) Protected: Endpoints within Sophos's deployment scope (scope itself unconfirmed)
Effectiveness: Weak — it failed to detect the crypto-miner running on `billing-srv-01`, and Marcus explicitly flagged that he never verified whether definitions/coverage were current across the endpoint fleet.
Source: IT service contracts (Sophos, Endpoint Protection, $18,000/yr); Marcus's "haven't gotten to" list

**C-004 — Veeam Nightly Backup**
Description: Automated nightly backups via a Veeam agent on `backup-srv-01` to a local NAS.
Category: Technical | Function: Corrective
Asset(s) Protected: Production servers within the backup schedule
Effectiveness: Weak — the backup target NAS sits in the *same server room, same network, same rack* as production, and the backup that was needed during the January ransomware event was found three weeks stale.
Source: IT service contracts (Veeam, $8,500/yr); Marcus's Servers section; Incident A

**C-005 — HID Global Badge Access System**
Description: Badge-based door access, integrated with Active Directory for *some* doors (coverage explicitly partial).
Category: Physical | Function: Preventive
Asset(s) Protected: A subset of restricted doors (exact scope, including whether the server room is covered, unconfirmed)
Effectiveness: Weak — the walk-through (Observation 1) confirms the server room uses the generic all-staff badge with no camera and no visitor log, so the preventive value at the most critical door is minimal.
Source: IT asset export (Badge/access system: HID Global, connected to AD for some doors); Observation 1

**C-006 — ClearView Security Guard Service**
Description: One contracted guard at Central's main entrance, Monday–Friday 7 AM–7 PM only.
Category: Physical | Function: Deterrent
Asset(s) Protected: Central main entrance during business hours only
Effectiveness: Adequate (but scope-limited) — no coverage at Westside or HQ, and no nights/weekends anywhere, which is precisely when the January ransomware executed ("over the weekend").
Source: IT service contracts (ClearView Security, $96,000/yr; "1 guard, main entrance, Mon-Fri 7AM-7PM. No weekend/night")

**C-007 — SSH Key-Based Authentication (Partial)**
Description: Migration from password-based to key-only SSH authentication on Linux servers — started by Marcus but completed only on `ehr-srv-01` before his departure.
Category: Technical | Function: Preventive
Asset(s) Protected: `ehr-srv-01` only; explicitly does NOT cover `billing-srv-01`, `backup-srv-01`, or `web-srv-01`, which still permit password authentication
Effectiveness: Weak org-wide / Adequate on the one host — an abandoned, incomplete control.
Source: Marcus Webb's `security_observations.txt` (Authentication section)

**C-008 — Site-to-Site VPN (IPSec)**
Description: Encrypted IPSec tunnels connecting Westside Clinic and Corporate HQ back to the FortiGate at Central.
Category: Technical | Function: Preventive
Asset(s) Protected: Inter-site traffic confidentiality/integrity
Effectiveness: Weak — the Westside tunnel runs through a *consumer-grade Netgear Nighthawk router* (Marcus called this "NOT acceptable for a medical facility"), and the HQ tunnel's ACLs have never been audited.
Source: Network diagram (IPSec VPN via Netgear router); Marcus's Network section

**C-009 — Guest / Internal WiFi SSID Separation**
Description: A separate guest SSID exists at Central alongside the internal network.
Category: Technical | Function: Preventive
Asset(s) Protected: Internal network segment (nominally)
Effectiveness: Weak — Marcus stated he was "not convinced it's actually isolated" and never verified it; Incident F independently proved an unmanaged device sat on the *internal* segment for three weeks.
Source: Marcus Webb's `security_observations.txt` (Network section); Incident F

**C-010 — MedTech Solutions EHR Maintenance Contract**
Description: Vendor-provided EHR software updates and patching, with a 4-hour SLA for critical issues and 24-hour for standard.
Category: Administrative | Function: Corrective (also Preventive via patch cadence)
Asset(s) Protected: `ehr-srv-01` / `ehr-db-01` software layer (explicitly excludes hardware)
Effectiveness: Adequate — a real SLA-backed contract, but scoped only to the EHR software and to nothing else in the environment.
Source: IT service contracts (MedTech Solutions, EHR maintenance, $145,000/yr; "SLA: 4hr response for critical, 24hr for standard")

**C-011 — Active Directory Domain Controllers**
Description: Centralized identity and authentication infrastructure (`ad-dc-01` / `ad-dc-02`, a redundant pair).
Category: Technical | Function: Preventive
Asset(s) Protected: Organization-wide authentication
Effectiveness: Adequate — redundant and functioning, but its value is undercut by the absence of MFA (C-012) and by the badge system depending on it for "some doors" only.
Source: IT asset export (`ad-dc-01` / `ad-dc-02`, Windows Server 2019)

**C-012 — Multi-Factor Authentication (single account)**
Description: MFA exists on exactly one account in the entire organization — James Chen's, which he configured himself.
Category: Technical | Function: Preventive
Asset(s) Protected: One executive account only
Effectiveness: Weak org-wide — this is really evidence of the *absence* of an organizational control; it is listed to make explicit how narrow its coverage is, and is carried into the Gap Analysis (Task 12, GAP-006).
Source: Marcus Webb's `security_observations.txt` ("No MFA anywhere except James's personal account")

**C-013 — Microsoft 365 (O365 E3) Managed Cloud Platform**
Description: Organization-wide managed productivity/email cloud suite under an enterprise licence.
Category: Technical | Function: Preventive (managed platform baseline)
Asset(s) Protected: Email and productivity data for all staff
Effectiveness: Adequate as a managed baseline, but its own security configuration (MFA enforcement, conditional access, DLP) is unconfirmed, and Marcus suspected additional *unsanctioned* cloud services exist alongside it.
Source: IT service contracts (Microsoft O365 E3, org-wide, $432,000/yr); Marcus's "haven't gotten to" list (cloud service inventory)

**C-014 — Radiology PACS Shared Login (documented as a control-of-record, rated failing)**
Description: A single shared credential (`raduser` / `radiology1`) used by the entire Radiology department to access the PACS workstation.
Category: Administrative | Function: Preventive (nominal) — in practice an anti-control
Asset(s) Protected: PACS workstation access (nominally)
Effectiveness: Weak — a shared credential provides no individual accountability and cannot be revoked for one person without disrupting the department; reported by Marcus, no action taken. Listed here so the inventory reflects reality rather than an idealized access-control posture.
Source: Marcus Webb's `security_observations.txt` (Authentication section)

## Control Summary Matrix

| Category \ Function | Preventive | Detective | Corrective | Compensating | Deterrent |
|---|---|---|---|---|---|
| **Technical** | C-001, C-003, C-007 (partial), C-008 (weak), C-009 (unverified), C-011, C-012 (1 account), C-013 | *(empty)* | C-004 (weakened by co-location) | *(empty)* | *(empty)* |
| **Administrative** | C-002, C-014 (failing) | *(empty)* | C-010 | *(empty)* | *(empty)* |
| **Physical** | C-005 (partial) | *(empty)* | *(empty)* | *(empty)* | C-006 (business-hours, Central-only) |

**Reading the matrix honestly.** Two things stand out once the real packet detail is applied. First, **every Detective cell is empty** across all three categories — the organization has no IDS/IPS, no centralized logging, no camera coverage of IT infrastructure, and no audit/review process. Second, the cell that *looks* strongest — Technical Preventive, with eight controls — is **Weak in aggregate**, because nearly every control there carries a specific, evidenced failure mode: the firewall protects only the perimeter of a flat internal network, SSH hardening reached one server, the VPN's Westside leg runs on consumer hardware, guest-WiFi isolation was never verified, and MFA covers a single account. Breadth of coverage and real effectiveness point in opposite directions. The **Compensating** column is entirely empty despite the MRI (Task 6) and `print-srv-01` (end-of-support since Oct 2023) both requiring exactly that category — which is why Task 6 has to design compensating controls from scratch.
