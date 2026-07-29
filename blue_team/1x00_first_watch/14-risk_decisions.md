# Risk Treatment Decisions

> **Budget note:** The $120,000 figure is a *new, dedicated security budget* separate from MedDefense's existing IT operational contracts (Sophos $18,000/yr, Veeam $8,500/yr, Fortinet support $4,200/yr, ClearView guard service $96,000/yr, MedTech EHR maintenance $145,000/yr, O365 $432,000/yr) — those are pre-existing costs, not available to reallocate, and are cited here only where they affect what a treatment can build on top of.

```yaml
Gap ID: GAP-006
Gap Title: MFA exists on exactly one account (James Chen's) in the entire organization
Risk Level: Critical

Treatment Strategy: Mitigate

Justification: MFA is one of the highest risk-reduction-per-dollar controls available and directly addresses the single most common real-world healthcare attack pattern identified in Task 13.

If Mitigate:
  - Proposed Control(s): Enforce MFA organization-wide for all remote access, administrative accounts, and EHR/PACS access (Technical, Preventive), starting with IT admin and remote-capable accounts (the ~30 remote-capable HQ laptops) in week one.
  - Estimated Cost: $1-10K (licensing plus rollout effort; the FortiGate and AD infrastructure already in place can support most MFA integrations without new hardware)
  - Implementation Effort: Short-term (< 1 month)
  - Expected Risk Reduction: Removes "a single stolen credential" as a sufficient condition for compromise across nearly every system in the organization.

Trade-offs: Requires staff enrollment and a short adjustment period; helpdesk (Mike Torres's team, 2 analysts) should expect a ticket spike during rollout.
```

```yaml
Gap ID: GAP-007
Gap Title: Unattended, unlocked EHR sessions at nurse stations
Risk Level: Critical

Treatment Strategy: Mitigate

Justification: The highest-consequence, lowest-cost fix available — a session timeout setting requires configuration effort, not capital spend.

If Mitigate:
  - Proposed Control(s): Enable automatic session timeout/lock on EHR client sessions (Technical, Preventive); replace the "do not log out" signage with clear guidance (Administrative, Preventive).
  - Estimated Cost: $0-1K
  - Implementation Effort: Quick Win (< 1 week)
  - Expected Risk Reduction: Eliminates the ongoing, passive exposure of Restricted patient data to any passerby.

Trade-offs: Clinical staff may push back on workflow friction; needs coordination with Clinical leadership, not just IT.
```

```yaml
Gap ID: GAP-009
Gap Title: Unlocked network closet with posted administrative credentials
Risk Level: Critical

Treatment Strategy: Mitigate

Justification: A near-zero-cost fix protecting a Critical asset category.

If Mitigate:
  - Proposed Control(s): Install a lock on the network closet door (Physical, Preventive); remove the posted credential sheet and rotate the exposed switch-management credentials (Technical + Administrative, Preventive).
  - Estimated Cost: $0-1K
  - Implementation Effort: Quick Win (< 1 week)
  - Expected Risk Reduction: Closes a fully open, zero-skill-required path to administrative network control.

Trade-offs: Minor operational adjustment for IT staff needing key/badge access instead of an unlocked door.
```

```yaml
Gap ID: GAP-003
Gap Title: EHR database reachable from the entire network, not restricted to the application server
Risk Level: Critical

Treatment Strategy: Mitigate

Justification: A firewall/ACL rule restricting PostgreSQL access to ehr-srv-01 only is a configuration change on infrastructure MedDefense already owns (the FortiGate and core switches), not a new purchase.

If Mitigate:
  - Proposed Control(s): Restrict ehr-db-01's PostgreSQL port to accept connections only from ehr-srv-01 (Technical, Preventive).
  - Estimated Cost: $0-1K (internal configuration effort)
  - Implementation Effort: Quick Win (< 1 week)
  - Expected Risk Reduction: Removes the ability for any compromised host on the flat network to reach the patient-record database directly.

Trade-offs: Requires testing to confirm no legitimate integration (e.g., a reporting tool) also depends on broader database access before restricting it.
```

```yaml
Gap ID: GAP-004
Gap Title: Westside Clinic has no firewall; VPN runs through a consumer-grade router
Risk Level: Critical

Treatment Strategy: Mitigate

Justification: Westside is the single least-defended site in the organization relative to the sensitivity of the data it handles; a dedicated business-grade firewall closes this gap directly.

If Mitigate:
  - Proposed Control(s): Deploy a dedicated firewall appliance at Westside, retiring the consumer-grade router from its security role (Technical, Preventive).
  - Estimated Cost: $1-10K (hardware plus configuration; small-site firewall appliances are inexpensive relative to enterprise-scale FortiGate deployments)
  - Implementation Effort: Short-term (< 1 month)
  - Expected Risk Reduction: Gives Westside a real perimeter for the first time and removes consumer-grade hardware from carrying the site-to-site VPN.

Trade-offs: Requires a site visit and brief connectivity interruption during cutover; should be scheduled outside clinic hours.
```

```yaml
Gap ID: GAP-005
Gap Title: Backup target (NAS) co-located with production (same room, network, rack)
Risk Level: Critical

Treatment Strategy: Mitigate

Justification: Real-world cases (Task 13) show this exact weakness turns a recoverable incident into a multi-week outage; offsite/cloud backup was already correctly identified by Marcus and denied only for budget reasons, which this year's dedicated security budget can now resolve.

If Mitigate:
  - Proposed Control(s): Establish an offsite or cloud backup destination in addition to the existing local NAS (Technical, Corrective); test a full restore from the new destination.
  - Estimated Cost: $10-50K (cloud storage/replication service plus initial transfer of the full backup set)
  - Implementation Effort: Short-term (< 1 month) for initial setup; ongoing
  - Expected Risk Reduction: Ensures a ransomware event or physical incident cannot destroy both production and its only recovery path simultaneously.

Trade-offs: Recurring cost in future budget cycles (cloud storage/egress fees), not a one-time expense; needs a documented, tested restore procedure to be worth the investment (see GAP-010 note below).
```

```yaml
Gap ID: GAP-001
Gap Title: No detective controls anywhere in the environment
Risk Level: Critical

Treatment Strategy: Mitigate

Justification: The single gap that, left untreated, undermines every other control in the environment. A full enterprise SIEM ($80K) is not affordable alongside the other six priorities this year, so mitigation is scoped to the Critical-rated assets first.

If Mitigate:
  - Proposed Control(s): Deploy a right-sized log aggregation and alerting tool (Technical, Detective), scoped first to ehr-srv-01/ehr-db-01, billing-srv-01, and the FortiGate/core switches.
  - Estimated Cost: $10-50K
  - Implementation Effort: Short-term (< 1 month) for initial deployment; Long-term for full organizational rollout including Westside and medical IoT
  - Expected Risk Reduction: Converts "discovery by a human noticing symptoms, after weeks" into "alerted within hours" for the highest-value targets.

Trade-offs: Endpoints, medical IoT (~200 devices), and Westside remain unmonitored this year; full-environment visibility is a multi-year build.
```

## Budget Summary

| Gap ID | Treatment | Estimated Cost (low-to-mid used for budgeting) |
|---|---|---|
| GAP-009 (network closet lock/credentials) | Mitigate | $750 |
| GAP-007 (EHR session timeout) | Mitigate | $500 |
| GAP-003 (EHR database ACL restriction) | Mitigate | $500 |
| GAP-006 (MFA org-wide) | Mitigate | $8,000 |
| GAP-004 (Westside firewall) | Mitigate | $6,000 |
| GAP-005 (offsite/cloud backup) | Mitigate | $25,000 |
| GAP-001 (detection tooling, priority assets) | Mitigate | $40,000 |
| **Total** | | **$80,750** |

This leaves approximately **$39,250 of the $120,000 budget** unallocated after the seven priority treatments. Recommended use of the remainder: begin the MRI network segmentation project (Task 6) as a distinct, smaller-scope line item (~$8,000, using existing FortiGate/switch hardware), with the balance reserved as implementation contingency. **Deferred to next fiscal year** (in order of priority): full flat-network VLAN segmentation at Central (GAP-002 — a project of a scale this year's budget cannot absorb alongside the above), the Radiology shared-credential fix (GAP-008), a formal incident response/BC/DR plan (GAP-010), a compensating-control framework for other legacy systems including `print-srv-01` (GAP-011), a formal HIPAA Security Rule assessment (GAP-012), and resolution of the outstanding shadow IT systems (GAP-013). These are deferred not because they are unimportant, but because this year's budget is deliberately concentrated on the gaps most directly tied to MedDefense's *already-demonstrated* compromise pattern and the specific, newly confirmed architectural weaknesses (flat network reachability, single-site firewall gap, backup co-location) most likely to reproduce it.
