# Control Gap Analysis

```
Gap ID: G-001
Gap Description: No intrusion detection, log aggregation, or alerting exists anywhere in the environment.
Category x Function Missing: Technical Detective
Affected Asset(s) or Zone: Organization-wide, most acutely billing-srv-01, ehr-db-01, and the flat 10.10.0.0/16 network as a whole
Risk if Unaddressed: Confidentiality and Integrity violations go unnoticed for weeks (as demonstrated by the cryptominer on billing-srv-01); on a fully flat network with no VLANs, an attacker who reaches any single host can reach every other host with no monitoring anywhere along the way.
Evidence: Control Matrix Task 4 — Technical Detective column entirely empty; Task 2 root cause analysis; network diagram confirms zero VLAN segmentation.
```

```
Gap ID: G-002
Gap Description: Entire network at Central is flat (10.10.0.0/16, no VLANs) — servers, workstations, medical IoT, and infusion pumps all share one broadcast domain.
Category x Function Missing: Technical Preventive (segmentation)
Affected Asset(s) or Zone: All 34 assets in the Asset Registry located at Central
Risk if Unaddressed: Compromise of any single low-value endpoint (a workstation, a thin client, even a printer) provides a direct path to the EHR database, billing server, domain controllers, and life-safety medical devices (infusion pumps, vital-signs monitors) with no network-layer barrier in between.
Evidence: Marcus Webb's security notes ("This is insane"); network diagram; segmentation was proposed and deferred ("planned for next fiscal year," said 4+ months ago).
```

```
Gap ID: G-003
Gap Description: Westside Clinic has no firewall of any kind; its entire network, including the site-to-site VPN to Central, runs through a consumer-grade Netgear router.
Category x Function Missing: Technical Preventive
Affected Asset(s) or Zone: Westside Clinic's entire local network (`ws-srv-01`, ~45 workstations) and, by extension, the VPN path into Central
Risk if Unaddressed: A compromise at Westside — the weakest-defended site in the organization — has a direct, minimally filtered path back into Central's core network via the VPN tunnel.
Evidence: Marcus Webb's security notes, explicitly calling this "NOT acceptable for a medical facility."
```

```
Gap ID: G-004
Gap Description: EHR database (`ehr-db-01`) accepts PostgreSQL connections from the entire `/16` network rather than only from `ehr-srv-01`.
Category x Function Missing: Technical Preventive
Affected Asset(s) or Zone: ehr-db-01 (patient records, prescriptions, lab results)
Risk if Unaddressed: Any compromised host anywhere on the flat network can attempt to connect directly to the database holding the organization's most sensitive data, bypassing the application layer entirely.
Evidence: Marcus Webb's security notes, explicit and specific.
```

```
Gap ID: G-005
Gap Description: Backup target (NAS) shares the same room, network, and rack as the production systems it backs up.
Category x Function Missing: Technical Corrective (control exists but is architecturally undermined)
Affected Asset(s) or Zone: backup-srv-01 and every system in its backup scope
Risk if Unaddressed: A single ransomware event or physical incident can destroy production and backup simultaneously — precisely the scenario that already unfolded in the January incident, where the backup that existed was also unusable (stale).
Evidence: Marcus Webb's security notes; offsite/cloud backup was proposed to James and denied on budget grounds; Incident A.
```

```
Gap ID: G-006
Gap Description: Multi-factor authentication exists on exactly one account (James Chen's) in the entire organization.
Category x Function Missing: Technical Preventive
Affected Asset(s) or Zone: Every account except one — including all IT administrative accounts, all clinical accounts, and all remote-access accounts
Risk if Unaddressed: A single compromised password (phishing, reuse, brute force) is sufficient to access any system organization-wide, with no second factor anywhere to stop it.
Evidence: Marcus Webb's security notes, stated directly and without qualification.
```

```
Gap ID: G-007
Gap Description: Shared login credential in use for the Radiology PACS workstation (`raduser`/`radiology1`).
Category x Function Missing: Administrative Preventive (accountability)
Affected Asset(s) or Zone: pacs-srv-01 and the PACS workstation
Risk if Unaddressed: No individual accountability exists for who accessed imaging data or the PACS system at any given time; a credential known to an entire department cannot be meaningfully revoked for one person without disrupting the whole team.
Evidence: Marcus Webb's security notes; reported to Sarah Park, no action taken.
```

```
Gap ID: G-008
Gap Description: No detective control exists anywhere in the physical domain relevant to IT infrastructure — existing cameras cover the parking garage and ER entrance, not the server room or network closet.
Category x Function Missing: Physical Detective
Affected Asset(s) or Zone: Server room, network closet
Risk if Unaddressed: Unauthorized physical entry cannot be identified or investigated after the fact.
Evidence: Marcus Webb's security notes; Observation 1 (Task 3).
```

```
Gap ID: G-009
Gap Description: No compensating control framework exists for unpatchable/end-of-life systems.
Category x Function Missing: Compensating (any category)
Affected Asset(s) or Zone: MRI workstation (Windows XP), print-srv-01 (Server 2012 R2, EOL Oct 2023), potentially the CT scanner (OS unconfirmed)
Risk if Unaddressed: Every legacy system identified so far is being handled reactively and individually, with no repeatable process, and at least one (print-srv-01) has apparently received no attention at all despite being over a year past end-of-support.
Evidence: Task 6 (MRI); IT asset export flags print-srv-01's EOL status with no noted remediation.
```

```
Gap ID: G-010
Gap Description: No formal incident response plan, business continuity plan, or disaster recovery plan exists in any documented form.
Category x Function Missing: Administrative Corrective
Affected Asset(s) or Zone: Organization-wide
Risk if Unaddressed: Incident response is improvised in real time (as it was for four days during the January ransomware event); Central's UPS covers only ~20 minutes of power loss with no documented procedure beyond that window.
Evidence: Marcus Webb's security notes, stated directly.
```

```
Gap ID: G-011
Gap Description: No formal HIPAA Security Rule compliance assessment has ever been conducted.
Category x Function Missing: Administrative Detective
Affected Asset(s) or Zone: Organization-wide (regulatory/governance layer)
Risk if Unaddressed: Legal's assertion that the organization "is compliant" has no supporting evidence; a real regulatory audit or a breach-triggered review would likely surface this as an aggravating factor.
Evidence: Marcus Webb's security notes, stated directly; James Chen is aware and concerned per the same source.
```

## Pattern Summary

Two patterns emerge once the real onboarding documentation is factored in, sharpening the original conclusion. First, **detection is still almost entirely absent**, exactly as identified before this packet was available — that conclusion holds and is now reinforced by a completely flat, unsegmented network with no monitoring anywhere along it. Second, and newly visible now, **several existing "preventive" controls are structurally self-defeating**: the backup exists but sits next to what it protects, the firewall exists but only at one site while a second clinical site has none at all, MFA exists but only for one person, and network segmentation was already identified as necessary and then deferred for a budget cycle that has already passed. MedDefense's posture is not simply "detection-light" — it is an environment where even the preventive layer has been repeatedly proposed, correctly diagnosed by the previous analyst, and then not resourced, which speaks to the same organizational friction (Security recommends, IT/leadership decides whether to act) identified in the org chart review (Task 0).
