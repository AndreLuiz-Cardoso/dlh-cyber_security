# Compensating Control Strategy — MRI Control Workstation

> **Update:** The IT asset export confirms the device as a **Siemens MAGNETOM MRI scanner**, located in Radiology at Central. The same export also flags a second, currently unaddressed legacy-system concern — `print-srv-01` (Windows Server 2012 R2, end-of-support since October 2023) — and an unconfirmed OS on the GE Revolution CT scanner, also in Radiology. The analysis and recommendations below focus on the MRI, but the same underlying gap (no compensating-control framework for unpatchable systems, GAP-009/G-009) should be applied to those systems as soon as their status is confirmed, rather than treating the MRI as an isolated case.

## 1. Risk Analysis

The MRI control workstation runs Windows XP Embedded, an operating system that has received no security patches since April 2014, meaning every vulnerability discovered in the last decade — including remotely exploitable, wormable flaws affecting the same SMB/networking stack XP shares with later Windows versions — remains permanently open on this machine. Because Central's entire network is confirmed flat — a single `10.10.0.0/16` broadcast domain with **no VLANs configured anywhere** — the MRI workstation does not merely share a segment with other clinical devices, it shares the same network as literally every server, workstation, and IoT device in the building, including the domain controllers and the EHR database. Any compromise anywhere on that network (a phished nurse-station machine, a compromised vital-signs monitor, an infusion pump) has a direct, unobstructed path to this easy, unpatchable target, and a compromise of the MRI workstation itself has an equally direct path back out to everything else. This turns a single legacy medical device into a standing foothold and lateral-movement bridge for the *entire organization's* Central network, not merely a risk contained to Radiology — and it is not an isolated case: the same flat-network exposure applies equally to the vital-signs monitors, infusion pumps, and print server, confirming this is a systemic segmentation gap (G-002 in the Control Gap Analysis) rather than a one-device problem.

## 2. Compensating Control Strategy

**Control 1 — Network Segmentation / Micro-VLAN Isolation**
What it does: Place the MRI workstation and its PACS communication path on a dedicated VLAN with a firewall rule set permitting only the specific traffic required to reach the PACS server — nothing else, in either direction.
Classification: Technical, Compensating (also functions as Preventive at the network layer)
Risk reduction: Removes the workstation from the flat network it currently shares with general endpoints, eliminating the primary lateral-movement path in both directions, without touching the OS or voiding certification.
Limitations/residual risk: Does not fix any vulnerability on the workstation itself — if an attacker reaches it through the permitted PACS channel, or physically, it is still exploitable. Requires accurate, tightly maintained firewall rules; a misconfiguration silently reopens the exposure.

**Control 2 — Network-Level Intrusion Detection / Anomaly Monitoring on the Segment**
What it does: Deploy a monitoring sensor (e.g., a network tap or span port feeding a detection tool) scoped to the MRI's new isolated VLAN, alerting on any traffic pattern outside the expected, narrow PACS communication baseline.
Classification: Technical, Compensating (functions as Detective)
Risk reduction: Since the device cannot be patched, detection becomes the primary way to catch exploitation attempts early rather than discovering compromise after downstream damage — directly closing the Technical Detective gap (G-001) for this specific critical asset.
Limitations/residual risk: Only as effective as the baseline definition and someone's ability to respond to alerts in a timely way; does not prevent a zero-day exploit attempt, only flags it.

**Control 3 — Restricted Physical Access to the MRI Control Room / Workstation**
What it does: Ensure the MRI control workstation is in a room with badge-restricted access limited to Radiology staff, rather than general clinical staff badge access, closing the physical avenue to a machine that cannot be secured through software patching.
Classification: Physical, Compensating (functions as Preventive)
Risk reduction: Reduces the pool of people who can physically interact with the workstation (insert removable media, reboot it, plug in a rogue device), which matters more than usual for a device that cannot be technically hardened.
Limitations/residual risk: Does not address network-borne attacks at all; only mitigates direct physical tampering, and badge systems organization-wide have already been shown to be poorly enforced (Observation 1).

**Control 4 — Administrative: Formal Risk Acceptance and Vendor Escalation Process**
What it does: Document the residual risk formally, obtain management/Board sign-off on accepted risk, and open a formal channel with the manufacturer to pursue either an extended-support patching agreement or a certified OS upgrade path ahead of the device's remaining ~6-year lifespan.
Classification: Administrative, Compensating
Risk reduction: Does not reduce technical risk directly, but ensures the risk is visible, owned, and being actively worked rather than sitting undocumented "on someone's desk" for six months, as it did under Marcus.
Limitations/residual risk: Pure paperwork without the technical controls above; must be paired with Controls 1–3 to have any real risk-reduction effect.

## 3. Implementation Priority

If only one control could be implemented immediately, it should be **Control 1 — Network Segmentation / Micro-VLAN Isolation**. Segmentation addresses the root structural problem identified in the Risk Analysis — the device's exposure is a function of its network position, not merely its unpatched state — and it is the only control on this list that meaningfully reduces risk in *both* directions (limiting what can reach the MRI, and limiting what the MRI can reach if compromised) without requiring new detection tooling, budget for continuous monitoring, or a change in physical access procedures that clinical staff may resist. It is also achievable with existing network hardware in most environments (VLAN and ACL configuration) rather than requiring new capital purchase, making it realistic under the same budget constraints affecting the rest of this assessment.
