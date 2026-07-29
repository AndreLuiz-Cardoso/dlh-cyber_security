# Complete Control Matrix

## Part 1: Control Registry (Updated)

| Control ID | Control Name | Category | Function | Asset(s) Protected | Effectiveness | Evidence/Source |
|---|---|---|---|---|---|---|
| C-001 | FortiGate 100F Perimeter Firewall | Technical | Preventive | All Central-hosted servers/apps; Westside/HQ traffic in transit | Adequate | Network diagram; contracts; the organization's only firewall — did not prevent Incidents A/cryptominer, which originated inside the network |
| C-002 | Corporate Password Policy | Administrative | Preventive | All user accounts | Weak | Marcus's own assessment ("not terrible but not great"); no MFA pairing anywhere except one account |
| C-003 | Sophos Endpoint Antivirus | Technical | Preventive | Endpoints in Sophos's scope (unconfirmed) | Weak | Failed to catch the billing-srv-01 cryptominer; fleet-wide currency never verified |
| C-004 | Veeam Nightly Backup | Technical | Corrective | Nominally all production servers | Weak | Backup NAS shares room/network/rack with production; found 3 weeks stale during the actual incident that needed it |
| C-005 | HID Global Badge Access | Physical | Preventive | Subset of restricted doors ("some") | Weak | Partial AD integration; Observation 1 shows a generic, non-differentiated badge at the server room |
| C-006 | ClearView Security Guard | Physical | Deterrent | Central main entrance, business hours only | Adequate (scope-limited) | Contract confirms Mon-Fri 7AM-7PM only; zero coverage at Westside/HQ or after hours |
| C-007 | SSH Key-Based Auth (partial) | Technical | Preventive | ehr-srv-01 only | Weak (org-wide); Adequate (single host) | Migration abandoned mid-way when Marcus departed; billing-srv-01 and backup-srv-01 remain password-auth |
| C-008 | Site-to-Site VPN (IPSec) | Technical | Preventive | Inter-site traffic (Westside, HQ) | Weak | Westside leg runs through a consumer router; HQ leg's ACLs never audited |
| C-009 | Guest/Internal WiFi Separation | Technical | Preventive | Internal network segment | Weak | Never verified as actually enforced; Incident F found an unmanaged device on the internal segment for 3 weeks |
| C-010 | MedTech Solutions EHR Maintenance | Administrative | Corrective | EHR software layer only | Adequate | 4hr/24hr SLA confirmed by contract; explicitly excludes hardware |
| C-011 | Active Directory Domain Controllers | Technical | Preventive | Org-wide authentication | Adequate | Redundant pair (ad-dc-01/02) confirmed in asset export |
| C-012 | MFA (single account) | Technical | Preventive | James Chen's account only | Weak (org-wide) | Confirmed by Marcus's notes as the sole instance in the organization |
| C-013 | Network Segmentation for MRI (proposed) | Technical | Compensating | MRI control workstation | *Not yet implemented* | Task 6 recommendation |
| C-014 | Network Anomaly Monitoring for MRI Segment (proposed) | Technical | Compensating | MRI control workstation | *Not yet implemented* | Task 6 recommendation |
| C-015 | Restricted Physical Access to MRI Room (proposed) | Physical | Compensating | MRI control workstation | *Not yet implemented* | Task 6 recommendation |

## Part 2: Updated Control Summary Matrix

| Category \ Function | Preventive | Detective | Corrective | Compensating | Deterrent |
|---|---|---|---|---|---|
| **Technical** | 8 controls (C-001, C-003, C-007, C-008, C-009, C-011, C-012, plus partial credit for C-002's technical enforcement) — avg. **Weak** | **0 — completely empty** | 1 control (C-004) — **Weak** | 2 proposed, not yet active (C-013, C-014) | 0 |
| **Administrative** | 1 control (C-002) — **Weak** | **0 — completely empty** | 1 control (C-010) — **Adequate** (scope-limited) | 0 | 0 |
| **Physical** | 1 control (C-005) — **Weak** | **0 — completely empty** | 0 | 1 proposed, not yet active (C-015) | 1 control (C-006) — **Adequate** (business-hours only) |

Now that real configuration detail is available, the picture is worse than the earlier draft assumed: it is not just that Detective and Compensating functions are empty — the *populated* Technical Preventive cell, which looks the most robust on paper (7 controls), is rated **Weak overall** because nearly every one of those controls has a confirmed, specific failure mode (partial SSH migration, unverified WiFi separation, a VPN leg on consumer hardware, MFA on one account). Breadth of coverage and actual effectiveness are pulling in opposite directions.

## Part 3: Control Coverage Map — Top 5 Critical Assets

| Critical Asset | Preventive | Detective | Corrective | Compensating | Coverage Assessment |
|---|---|---|---|---|---|
| EHR System (`ehr-srv-01`/`ehr-db-01`) | Password policy (C-002, Weak), partial SSH hardening (C-007, ehr-srv-01 only), AD (C-011) | None | MedTech maintenance (C-010, Adequate, software only) | None | Under-Protected — no detection at all, and the database itself is reachable from the entire flat network regardless of any of these controls |
| Medical IoT — Infusion Pumps/Vital-Signs Monitors | None confirmed specific to this category | None | None | None | Unprotected — no control in the registry is scoped to these ~200 life-safety devices specifically; they inherit only the general network's (weak) perimeter protection |
| Pharmacy Management System | Password policy (C-002, Weak) only, by assumption | None | None | None | Unprotected — compounded by the fact that no server hosting this system is even confirmed in MedDefense's own asset export |
| PACS / MRI / CT Imaging Chain | Firewall (C-001, indirect, perimeter only) | None | None | Proposed only (C-013–C-015, not implemented) | Unprotected — currently relies entirely on controls not yet built |
| Network Core Infrastructure | Firewall (C-001), badge access (C-005, Weak) | None | None | None | Under-Protected — the layer everything else depends on has a single firewall for the whole organization and an unlocked closet housing the switches |
