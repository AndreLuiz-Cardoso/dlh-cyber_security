# Prioritized Gap Analysis

```
Gap ID: GAP-001
Title: No detective controls anywhere in the environment
Affected Asset(s): EHR System (Critical), Billing Server (High), Medical IoT (Critical), Network Core (Critical)
Data at Risk: Patient medical records (Restricted), financial data (Confidential), imaging data (Restricted)
Current Control Status: Zero Detective controls in any category (Control Matrix Task 10, Part 2)
Risk Level: Critical
Risk Justification: Affects every Critical-rated asset with zero detective or corrective coverage functioning effectively.
Potential Impact: Compromises persist for weeks undetected, as already demonstrated twice on billing-srv-01, across a network with no monitoring anywhere along it.
```

```
Gap ID: GAP-002
Title: Entire Central network is flat (10.10.0.0/16, no VLANs) — servers, workstations, and life-safety IoT share one broadcast domain
Affected Asset(s): Medical IoT (Critical), EHR System (Critical), Network Core (Critical)
Data at Risk: All data at Central, effectively
Current Control Status: No segmentation control exists; proposed and deferred a fiscal year ago
Risk Level: Critical
Risk Justification: A Critical-rated life-safety asset category (infusion pumps, vital-signs monitors) has no network isolation from any other asset in the building, including the domain controllers.
Potential Impact: Compromise of any single low-value endpoint provides a direct path to patient-safety-critical devices and the EHR database.
```

```
Gap ID: GAP-003
Title: EHR database reachable from the entire network, not restricted to the application server
Affected Asset(s): EHR System (Critical)
Data at Risk: Patient medical records (Restricted)
Current Control Status: No database-level network restriction
Risk Level: Critical
Risk Justification: The single most sensitive data store in the organization is reachable from every device on the flat network, not just its own application tier.
Potential Impact: Any compromised host anywhere can attempt direct, application-bypassing access to patient records.
```

```
Gap ID: GAP-004
Title: Westside Clinic has no firewall; its VPN to Central runs through a consumer-grade router
Affected Asset(s): Westside Clinic Infrastructure (High)
Data at Risk: Westside operational/scheduling data (Confidential); indirectly, all data reachable via the VPN into Central
Current Control Status: No firewall at this site at all (Control Matrix Task 10)
Risk Level: Critical
Risk Justification: The weakest-defended site in the organization has a direct network path into Central's core.
Potential Impact: A compromise at Westside has minimal filtering standing between it and the rest of the organization.
```

```
Gap ID: GAP-005
Title: Backup target (NAS) co-located with production (same room, network, rack)
Affected Asset(s): Backup Infrastructure (Critical), Billing Server (High), EHR System (Critical)
Data at Risk: All backed-up data, effectively
Current Control Status: Veeam backup exists (C-004) but is architecturally undermined
Risk Level: Critical
Risk Justification: A single incident can destroy production and its recovery path simultaneously — already partially demonstrated in the January ransomware event.
Potential Impact: A future ransomware event could leave MedDefense with no viable recovery path at all, not just a stale one.
```

```
Gap ID: GAP-006
Title: MFA exists on exactly one account (James Chen's) in the entire organization
Affected Asset(s): Every system reachable via any other credential — EHR, billing, network core, admin accounts
Data at Risk: Everything protected only by a password
Current Control Status: C-012 in the Control Matrix, effectively a non-control at organizational scale
Risk Level: Critical
Risk Justification: A single stolen credential — the most common real-world initial access vector — is sufficient to compromise any system except one account.
Potential Impact: Matches the exact pattern behind numerous real-world healthcare ransomware and data-theft incidents.
```

```
Gap ID: GAP-007
Title: Unattended, unlocked EHR sessions at nurse stations
Affected Asset(s): Clinical Endpoints (High), EHR System (Critical, as data source)
Data at Risk: Patient medical records (Restricted)
Current Control Status: No session timeout; a posted sign actively discourages logging out
Risk Level: Critical
Risk Justification: Restricted data with no control at the point of use, undermined by organizational norms.
Potential Impact: Ongoing, low-effort exposure of PHI to any passerby.
```

```
Gap ID: GAP-008
Title: Shared login credential for the Radiology PACS workstation (raduser/radiology1)
Affected Asset(s): PACS/Imaging Chain (Critical)
Data at Risk: Medical imaging data (Restricted)
Current Control Status: Reported to IT, no action taken
Risk Level: High
Risk Justification: No individual accountability for access to a Critical-rated system; affects a High-value asset with an incomplete administrative control.
Potential Impact: Cannot investigate or attribute unauthorized PACS access to any individual.
```

```
Gap ID: GAP-009
Title: Unlocked network closet with posted administrative credentials
Affected Asset(s): Network Core Infrastructure (Critical)
Data at Risk: All data in transit across the network
Current Control Status: Badge access exists org-wide but not for this specific zone
Risk Level: Critical
Risk Justification: A Critical asset with no effective control coverage for this specific physical zone.
Potential Impact: Full administrative compromise of network switching with no technical skill required.
```

```
Gap ID: GAP-010
Title: No formal incident response, business continuity, or disaster recovery plan exists
Affected Asset(s): Organization-wide
Data at Risk: All data and services, indirectly
Current Control Status: No documented plan of any kind; UPS covers ~20 minutes
Risk Level: High
Risk Justification: The January ransomware response was fully improvised over four days; affects High-impact operational continuity org-wide.
Potential Impact: A future incident's response time and effectiveness depend entirely on the improvisational skill of whoever is on shift that day.
```

```
Gap ID: GAP-011
Title: No compensating-control framework for unpatchable/end-of-life systems (MRI, print-srv-01, possibly the CT scanner)
Affected Asset(s): PACS/MRI Imaging Chain (Critical), print-srv-01 (Medium)
Data at Risk: Medical imaging data (Restricted)
Current Control Status: Handled reactively and individually; print-srv-01 has received no apparent attention despite 18+ months past end-of-support
Risk Level: High
Risk Justification: A systemic process gap affecting a Critical asset category and at least one other confirmed legacy system.
Potential Impact: Every future legacy system discovered faces the same undefined, slow path to remediation the MRI has.
```

```
Gap ID: GAP-012
Title: No formal HIPAA Security Rule compliance assessment has ever been conducted
Affected Asset(s): Organization-wide (governance layer)
Data at Risk: All Restricted/Confidential data, from a regulatory-exposure standpoint
Current Control Status: Legal asserts compliance with no supporting evidence
Risk Level: High
Risk Justification: A governance gap compounding every technical gap above; increases regulatory exposure if any of the above gaps is exploited.
Potential Impact: A breach investigation would likely find an absence of due diligence, worsening regulatory and financial consequences.
```

```
Gap ID: GAP-013
Title: Shadow IT operating outside all official controls (NAS, Google Drive, Raspberry Pi) plus unconfirmed additional departmental cloud services
Affected Asset(s): Administrative Endpoints/Data (Medium-High)
Data at Risk: Research data, marketing communications, unknown Raspberry Pi data
Current Control Status: None — outside every control in the registry by definition
Risk Level: High
Risk Justification: Affects data categories with zero control coverage; Marcus's own notes suspect this understates the true scope (unconfirmed departmental cloud use beyond O365).
Potential Impact: Undetected compromise or data loss with no visibility, potentially broader than the three systems currently known.
```

## Gap Distribution Summary

**By risk level:** 9 Critical (GAP-001 through 007, 009), 4 High (GAP-008, 010, 011, 012, 013 — 5 total High).

**Asset categories with the most gaps:** The **network/architecture layer** (flat network, Westside's missing firewall, the database's open reachability, the unlocked closet — GAP-002, 003, 004, 009) and **critical clinical systems** (EHR, PACS, medical IoT — GAP-001, 002, 003, 006, 007, 008) are the two most gap-dense categories, together accounting for the large majority of all gaps identified.

**Concentration by control function:** As in the prior analysis, **Detective controls remain the single most consistently absent function** — but the newly confirmed onboarding data reveals a second, equally serious concentration: **structural/architectural Preventive gaps** (flat network, open database, single-account MFA, one firewall for the whole organization) that were not visible before this documentation was available. The organization's exposure is now confirmed to be broader than "we can't see incidents" — it also has very little to actually stop lateral movement once any single foothold is gained anywhere in the environment.
