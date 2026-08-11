# Prioritized Gap Analysis

> **Method.** Each gap below is produced by cross-referencing three inputs for every finding: (1) the **asset criticality** rating from the Criticality Assessment (Task 8), (2) the **data sensitivity** classification from the Data Map (Task 9), and (3) the **control status** from the Complete Control Matrix (Task 10). The Risk Justification for each gap states all three together in a single line, because the risk level is a function of their combination — a missing control matters more on a Critical asset holding Restricted data than the same missing control on a Low asset holding Public data. Priority levels follow the fixed rules stated after the gap list.

```
Gap ID: GAP-001
Title: No detective controls anywhere in the environment
Affected Asset(s): EHR System (Critical), Billing Server (High), Pharmacy System (Critical), Medical IoT (Critical), Network Core (Critical)
Data at Risk: Patient medical records (Restricted), dosage data (Restricted), financial data (Confidential), imaging data (Restricted)
Current Control Status: Zero Detective controls in any category (Task 10 matrix — the entire Detective column is empty); only weak antivirus status reporting exists
Risk Level: Critical
Risk Justification: Cross-referencing all three axes — the affected assets are Critical (EHR, Pharmacy, Medical IoT, Network Core), the data is the organization's most sensitive (Restricted PHI and dosage data), and the control status is total absence of the detective function — this is the highest-severity combination possible: maximum asset value, maximum data sensitivity, zero detective coverage.
Potential Impact: Compromises persist for weeks undetected, as already demonstrated twice on billing-srv-01, across a network with no monitoring anywhere along it.
```

```
Gap ID: GAP-002
Title: Entire Central network is flat (10.10.0.0/16, no VLANs) — servers, workstations, and life-safety IoT share one broadcast domain
Affected Asset(s): Medical IoT (Critical), EHR System (Critical), Network Core (Critical)
Data at Risk: Patient records (Restricted), plus effectively all data at Central
Current Control Status: No segmentation control exists (Task 10 — no Technical Preventive segmentation); proposed and deferred a fiscal year ago
Risk Level: Critical
Risk Justification: Critical-rated life-safety assets (infusion pumps, vital-signs monitors) and Restricted patient data share one broadcast domain with every other device, and the segmentation control that would contain this is entirely absent — Critical asset × Restricted data × missing preventive control.
Potential Impact: Compromise of any single low-value endpoint provides a direct path to patient-safety-critical devices and the EHR database.
```

```
Gap ID: GAP-003
Title: EHR database reachable from the entire network, not restricted to the application server
Affected Asset(s): EHR System (Critical)
Data at Risk: Patient medical records (Restricted)
Current Control Status: No database-level network access restriction (Task 10 — no Technical Preventive ACL on ehr-db-01)
Risk Level: Critical
Risk Justification: The Critical EHR database holding Restricted PHI is reachable from every host on the flat network, with no access-restriction control in place — the highest-value asset and highest data sensitivity combined with an absent preventive control.
Potential Impact: Any compromised host anywhere can attempt direct, application-bypassing access to patient records.
```

```
Gap ID: GAP-004
Title: Westside Clinic has no firewall; its VPN to Central runs through a consumer-grade router
Affected Asset(s): Westside Clinic Infrastructure (High); indirectly Network Core (Critical) via the VPN
Data at Risk: Westside operational/scheduling data (Confidential); indirectly all Central data (up to Restricted) reachable through the tunnel
Current Control Status: No firewall exists at this site at all (Task 10 — the FortiGate is Central-only); the VPN runs on consumer hardware
Risk Level: Critical
Risk Justification: A High site that is a direct network path into the Critical Network Core, carrying Confidential local data and bridging to Restricted Central data, is protected by no perimeter control whatsoever — the absent control elevates a High-asset gap to Critical because of what it bridges into.
Potential Impact: A compromise at Westside has minimal filtering standing between it and the rest of the organization.
```

```
Gap ID: GAP-005
Title: Backup target (NAS) co-located with production (same room, network, rack)
Affected Asset(s): Backup Infrastructure (Critical), Billing Server (High), EHR System (Critical)
Data at Risk: All backed-up data (up to Restricted), effectively
Current Control Status: Veeam backup exists (C-004) but is architecturally undermined; no isolated/offsite copy (Task 10 — Corrective control rated Weak)
Risk Level: Critical
Risk Justification: The Critical recovery capability protecting Restricted data exists as a control on paper but is co-located with what it protects, so its effective status is failing — Critical asset × Restricted data × a corrective control that cannot survive the event it exists for.
Potential Impact: A future ransomware event could leave MedDefense with no viable recovery path at all, not just a stale one.
```

```
Gap ID: GAP-006
Title: MFA exists on exactly one account (James Chen's) in the entire organization
Affected Asset(s): Every system reachable by credential — EHR (Critical), Billing (High), Network Core (Critical), all admin accounts
Data at Risk: Everything protected only by a password, up to Restricted PHI
Current Control Status: C-012 exists on one account only (Task 10 — Weak); effectively no organizational MFA
Risk Level: Critical
Risk Justification: Every Critical asset and all Restricted data are reachable with a single-factor credential because the MFA control covers exactly one account — Critical assets × Restricted data × a preventive control present at ~0% coverage.
Potential Impact: A single stolen credential — the most common real-world initial access vector — is sufficient to compromise any system except one account.
```

```
Gap ID: GAP-007
Title: Unattended, unlocked EHR sessions at nurse stations
Affected Asset(s): Clinical Endpoints (High), EHR System (Critical, as the data source)
Data at Risk: Patient medical records (Restricted)
Current Control Status: No session-timeout control; organizational signage actively discourages logging out (Task 10 — no Technical Preventive session control)
Risk Level: Critical
Risk Justification: Restricted PHI from the Critical EHR is exposed at the point of use with no timeout control and a policy that undermines the one behavioural control that existed — Critical data source × Restricted data × an absent (and counter-productive) control.
Potential Impact: Ongoing, low-effort exposure of PHI to any passerby — the lowest-effort exploitation path in the assessment.
```

```
Gap ID: GAP-008
Title: Shared login credential for the Radiology PACS workstation (raduser/radiology1)
Affected Asset(s): PACS / Imaging Chain (Critical)
Data at Risk: Medical imaging data (Restricted)
Current Control Status: Shared account in use; reported to IT, no action taken (Task 10 — C-014, Weak, no individual accountability)
Risk Level: High
Risk Justification: A Critical imaging system holding Restricted data is accessed through a shared credential that provides no individual accountability — the data sensitivity is maximal but the control is incomplete rather than wholly absent, placing this at High.
Potential Impact: Unauthorized PACS access cannot be attributed to or investigated for any individual.
```

```
Gap ID: GAP-009
Title: Unlocked network closet with switch-management credentials posted on the wall
Affected Asset(s): Network Core Infrastructure (Critical)
Data at Risk: All data in transit across the network (all classifications, effectively)
Current Control Status: Badge access exists org-wide but does not cover this zone; no lock; credentials in plain view (Task 10 — C-005 does not cover this zone)
Risk Level: Critical
Risk Justification: The Critical Network Core, whose compromise exposes data in transit up to Restricted, has no effective physical control for this specific zone and its admin credentials are exposed — Critical asset × Restricted-class exposure × a preventive control that does not reach the zone at all.
Potential Impact: Full administrative compromise of network switching with no technical skill required.
```

```
Gap ID: GAP-010
Title: No documented incident response, business continuity, or disaster recovery plan
Affected Asset(s): Organization-wide (all Critical and High assets in a real incident)
Data at Risk: All data and services, indirectly (up to Restricted)
Current Control Status: No documented plan of any kind (Task 10 — no Administrative Corrective process); UPS covers ~20 minutes
Risk Level: High
Risk Justification: Every Critical asset depends in an incident on a response capability that does not exist in documented form — the January ransomware response was improvised over four days — so the affected scope is Critical and the data is Restricted, but it is rated High rather than Critical because it is a process gap that compounds other gaps rather than a directly exploitable technical exposure.
Potential Impact: A future incident's speed and effectiveness depend entirely on who happens to be on shift that day.
```

```
Gap ID: GAP-011
Title: No compensating-control framework for unpatchable/end-of-life systems (MRI, print-srv-01, possibly the CT scanner)
Affected Asset(s): PACS / MRI Imaging Chain (Critical); print-srv-01 (Medium)
Data at Risk: Medical imaging data (Restricted)
Current Control Status: Handled reactively, one device at a time; no framework (Task 10 — Compensating column entirely empty); print-srv-01 unaddressed 18+ months past end-of-support
Risk Level: High
Risk Justification: A Critical imaging asset holding Restricted data, plus at least one other confirmed end-of-life system, is protected by no compensating-control process at all — the data sensitivity is maximal and the control category is entirely absent, but it is rated High because it is a systemic process gap distinct from the MRI's specific technical exposure already captured in GAP-002/GAP-003.
Potential Impact: Every future legacy system discovered faces the same undefined, slow path the MRI faced.
```

```
Gap ID: GAP-012
Title: No formal HIPAA Security Rule compliance assessment has ever been conducted
Affected Asset(s): Organization-wide (governance layer)
Data at Risk: All Restricted/Confidential data from a regulatory-exposure standpoint
Current Control Status: Legal asserts compliance with no supporting evidence (Task 10 — no Administrative Detective/audit process)
Risk Level: High
Risk Justification: The organization handling Restricted PHI across Critical clinical systems has never validated its regulatory control posture, so the asset scope and data sensitivity are maximal while the governance control is absent — rated High because it aggravates the consequences of every other gap rather than being independently exploitable.
Potential Impact: A breach investigation would likely find an absence of due diligence, worsening regulatory and financial penalties.
```

```
Gap ID: GAP-013
Title: Shadow IT outside all controls (NAS, Google Drive, Raspberry Pi) plus suspected additional cloud services
Affected Asset(s): Administrative Endpoints/Data (Medium-High)
Data at Risk: Cardiology research data (Confidential-Restricted), marketing communications (Internal), unknown Raspberry Pi data
Current Control Status: None — outside every control in the registry by definition (Task 10 — no coverage)
Risk Level: High
Risk Justification: Systems potentially holding Confidential-to-Restricted data operate with zero control coverage of any kind, and Marcus's notes suggest the true scope is under-counted — High-to-Restricted data × Medium-High assets × complete absence of controls.
Potential Impact: Undetected compromise or data loss with no visibility, potentially broader than the three known systems.
```

```
Gap ID: GAP-014
Title: Unmanaged / unencrypted mobile devices (remote laptops, physician iPads)
Affected Asset(s): HQ laptops (~30, Medium-High), physician iPads (~25, High as EHR access points)
Data at Risk: Patient medical records (Restricted) via iPads; Confidential HQ data on laptops
Current Control Status: MDM enrollment and at-rest encryption unconfirmed; no confirmed mobile asset-control process (Task 10 — no confirmed Technical Preventive coverage)
Risk Level: High
Risk Justification: High-value EHR-access devices and Confidential-data laptops carry Restricted PHI with an unconfirmed and likely-absent encryption/MDM control — High assets × Restricted data × a preventive control that cannot be evidenced.
Potential Impact: A single lost or stolen unencrypted device holding or accessing PHI is an independently reportable breach.
```

## Gap Distribution Summary

The fourteen gaps were scored by cross-referencing asset criticality, data sensitivity, and control status. The distribution below is broken down along the three axes the priority rules depend on.

**By risk level.** Of the 14 gaps, **8 are Critical** (GAP-001, 002, 003, 004, 005, 006, 007, 009) and **6 are High** (GAP-008, 010, 011, 012, 013, 014); there are 0 Medium and 0 Low. This skew is itself a finding: because the gaps were surfaced through incidents, a physical walk-through, and the confirmed network architecture, almost every one touches a Critical asset or Restricted data — the environment has few *minor* problems, which is a sign the posture is weak at the foundational layer rather than at the edges.

**By affected asset category.** The gaps concentrate in two categories that together account for 11 of the 14. The **network / infrastructure layer** carries 5 (GAP-002 flat network, GAP-003 exposed database, GAP-004 Westside firewall, GAP-005 backup co-location, GAP-009 network closet), and the **critical clinical systems** — EHR, Pharmacy, PACS/MRI, Medical IoT — carry 6 (GAP-001, 002, 003, 006, 007, 008), with GAP-002 and GAP-003 sitting in both. The remaining three are governance/process (GAP-010, 011, 012) and one shadow-IT/mobile cluster (GAP-013, 014). The clustering means a relatively small number of structural fixes — segmentation, MFA, isolated backup, detection — would each close *multiple* gaps at once.

**By control category and function.** This is the most important axis. Mapping each gap to the missing control shows the deficit is not spread evenly: it concentrates overwhelmingly in **Detective controls** (GAP-001 explicitly, and GAP-009/GAP-012 implicitly, since without detection or audit nothing else's failure is caught) and in **structural Technical Preventive controls** (GAP-002, 003, 004, 006 — segmentation, access restriction, perimeter, MFA). The **Compensating** category is absent entirely (GAP-011), and **Administrative Corrective** process is absent (GAP-010). By contrast, no gap here is caused by a *missing basic preventive* control in the ordinary sense — MedDefense has a firewall, antivirus, passwords, and backups. The gaps exist because those controls are either bypassed at the credential layer, undermined architecturally, or unmatched by any detection to catch their failure. In one sentence: **MedDefense's exposure is not that it lacks prevention, but that its prevention is structurally porous and its detection is entirely absent** — which is precisely why an attacker's foothold, once gained, goes unnoticed and unbounded, exactly as `billing-srv-01` demonstrated twice.
