# MedDefense Health Systems — Security Posture Assessment

Prepared for: Board of Directors
Prepared by: Security Analyst, Office of the Deputy CISO
Date: [assessment week]

---

## 1. Executive Summary

MedDefense's security posture today is **prevention-thin and detection-blind**: a small set of basic controls exist, but several of them are structurally undermined by the way they were implemented, and the organization has almost no ability to notice when they fail. The single most critical finding is that the entire Central hospital network — including patient monitors, infusion pumps, and the domain controllers — runs as one flat, unsegmented network with no internal barriers, while the core billing server has already been compromised twice without anyone realizing it for weeks. Our top three recommended actions are: (1) require a second login step (multi-factor authentication) everywhere, since today it exists on exactly one account in the whole organization; (2) close two zero-cost gaps that leave patient records exposed — an unattended nurse-station screen and a patient database reachable from any device on the network; and (3) build basic detection capability for our three most critical systems. Together, these recommendations require roughly two-thirds of this year's proposed $120,000 security budget and directly address the same failure pattern — a single compromised credential or device going unnoticed for an extended period — that has caused major, publicly reported breaches at other healthcare organizations.

## 2. Scope and Methodology

**Assessed:** All three MedDefense sites (Central, Westside Clinic, Corporate HQ); the EHR, billing, pharmacy, PACS/imaging, and patient portal systems; core network infrastructure at all three sites; the confirmed medical IoT fleet (patient monitors, infusion pumps, MRI, CT); and physical security at MedDefense Central.

**Sources used:** The complete internal onboarding documentation package (HR site guide, IT asset export, network diagram, IT service contracts, org chart, and the previous security analyst's working notes), a six-month incident log, direct diagnostic review of the billing server, an in-person physical walk-through of MedDefense Central, a legacy-device case review (the MRI scanner), informal disclosure of unmanaged systems by IT staff, and correlation against publicly documented healthcare-sector breach patterns.

**Limitations and assumptions:** This assessment is artifact-, interview-, and documentation-based, not a live technical scan. A live network scan, a full staff training record, exact firewall rule sets, and the previous analyst's fully completed draft report were not available and would likely surface additional detail (a true current endpoint count, an unconfirmed second Westside server, and any unsanctioned departmental cloud services beyond Microsoft 365). The patterns identified — a completely flat network, single-account MFA, repeated compromise of the same asset, and near-total absence of detection — are independently corroborated across multiple sources within the available documentation and are not expected to change materially as further detail emerges.

## 3. Asset Landscape

The registry built during this assessment documents 34 distinct assets: 10 servers at Central, 1-2 at Westside, core network hardware at all three sites, a confirmed medical IoT fleet of roughly 200 life-safety devices (Philips patient monitors, BD Alaris infusion pumps) plus an MRI and CT scanner, and three known unmanaged ("shadow IT") systems.

**Top 5 critical assets:**
1. **EHR System (`ehr-srv-01` / `ehr-db-01`)** — the record every physician relies on for treatment decisions; its database is currently reachable from the entire network rather than restricted to its application server.
2. **Medical IoT — Infusion Pumps and Patient Monitors (~200 devices)** — a data-integrity or availability failure here is a direct, immediate life-safety risk, and these devices share the same unsegmented network as every workstation in the building.
3. **Pharmacy Management System** — already produced a hospital-wide incorrect-dosage display, caught only by a pharmacist's manual check; notably, no server in MedDefense's own IT records is confirmed to host this system.
4. **PACS / MRI / CT Imaging Chain** — the MRI is confirmed to run on a decade-unsupported operating system; the CT scanner's OS status is unconfirmed.
5. **Network Core Infrastructure** — the organization operates a single firewall for three sites, has zero network segmentation at its largest facility, and its physical hub (the network closet) was found unlocked with administrative passwords posted on the wall.

**Data classification summary:** MedDefense handles Restricted-tier data (patient medical records, lab results, imaging, dosage data, system credentials) and Confidential-tier data (financial/billing records, employee HR records) across all three sites. The widest protection gap is Restricted-tier patient data, which is exposed in two independent ways simultaneously: visually, at unattended clinical workstations, and technically, through a database reachable from anywhere on the network.

## 4. Current Security Controls

Fifteen distinct controls were identified across all three categories (Technical, Administrative, Physical). The organization has **broad but shallow prevention**: a firewall, a password policy, backup software, a guard contract, and badge access all exist on paper, but nearly every one of them has a confirmed, specific failure mode once real configuration detail is examined — the firewall exists at only one of three sites, the backup NAS shares a rack with the production it protects, the guard covers business hours at one location only, and multi-factor authentication covers a single account. **No Detective control exists anywhere in any category**, and **no Compensating control has been implemented** despite a known unpatchable medical device (the MRI) and at least one other end-of-life system (`print-srv-01`, unsupported since October 2023) requiring exactly that treatment.

## 5. Gap Analysis

Thirteen gaps were identified: 9 Critical, 4 High.

**Critical gaps:**
- **No detective controls anywhere** — the root reason compromises go unnoticed for weeks.
- **The entire Central network is flat**, with life-safety medical devices sharing a broadcast domain with every server and workstation in the building.
- **The patient-record database is reachable from any device on the network**, not restricted to its own application server.
- **Westside Clinic has no firewall at all**; its connection back to Central runs through a consumer-grade home router.
- **The organization's only backup sits in the same room, network, and rack as the production systems it protects.**
- **Multi-factor authentication exists on exactly one account in the entire organization.**
- **Patient records are left visible on unattended screens**, actively encouraged by current signage.
- **A network closet housing core switches is unlocked**, with administrative credentials posted in plain view.

**High gaps:** a shared login credential used by an entire clinical department for imaging system access; no documented incident response, business continuity, or disaster recovery plan (the January ransomware response was fully improvised over four days); no process for handling other unpatchable legacy systems beyond the one already identified; no formal HIPAA Security Rule compliance assessment has ever been conducted; and three confirmed unmanaged "shadow IT" systems.

**Gap distribution:** Gaps concentrate around two areas equally — the near-total absence of **detection** as a control function, and previously unrecognized **architectural weaknesses** (the flat network, the single-site firewall gap, the co-located backup) that only became visible once the organization's actual network and asset documentation was reviewed in full.

## 6. Risk Treatment Recommendations

Seven priority treatments were selected, all under a **Mitigate** strategy, totaling approximately **$80,750 of the $120,000 annual budget**:

| Priority | Action | Cost | Timeline |
|---|---|---|---|
| 1 | Lock the network closet, rotate exposed credentials | $750 | Quick Win |
| 2 | Enable EHR session timeout | $500 | Quick Win |
| 3 | Restrict the patient database to its application server only | $500 | Quick Win |
| 4 | Enforce multi-factor authentication organization-wide | $8,000 | Short-term |
| 5 | Deploy a real firewall at Westside Clinic | $6,000 | Short-term |
| 6 | Establish offsite/cloud backup, tested for restore | $25,000 | Short-term |
| 7 | Deploy detection/logging for the top 3 critical systems | $40,000 | Short-term to Long-term |

The remaining ~$39,250 is earmarked first for the MRI network-segmentation project already scoped in our legacy-device review (~$8,000, using existing firewall/switch hardware), with the balance held as implementation contingency. Deferred to next fiscal year: full network segmentation for the entire Central facility, the Radiology shared-credential fix, a formal incident response/continuity plan, a repeatable process for other legacy systems, a formal HIPAA assessment, and resolution of the remaining shadow IT systems.

## 7. Conclusion and Next Steps

MedDefense's security posture, in business terms, is that of an organization that has already been breached more than once and currently has very few internal barriers to stop the next credential theft or device compromise from reaching its most sensitive systems — the entire hospital network, including life-safety medical devices, functions as a single unprotected space once any single point of entry is found. If these recommendations are not implemented, the most likely outcome — based on MedDefense's own recent history and comparable industry cases — is an extended, multi-day-or-longer disruption to patient care or billing operations, triggered by the same kind of single compromised credential already seen twice this year. Once this internal remediation program is underway, the logical next phase, as our previous analyst began to outline before his departure, is a formal **External Threat Landscape Assessment**: mapping which threat actor categories and attack techniques are most relevant to a regional hospital group like MedDefense, so future budget cycles can be prioritized by what is actually being used against organizations like ours, not just by what we happen to have found first.
