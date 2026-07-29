# Structured Environment Summary — MedDefense Health Systems

> **Sourcing note:** This version supersedes the earlier draft. It is built directly from the full onboarding documentation package (HR onboarding guide, IT asset export, Marcus Webb's `security_observations.txt`, IT service contracts summary, network diagram draft, and org chart), cross-referenced against the incident log, physical walk-through, and MRI case file already established in this assessment. Where the packet's content differs from earlier assumptions, or from what the physical walk-through directly observed, that is called out explicitly in Section 4 rather than silently reconciled.

## 1. Organization Overview

| Site | Location Type | Function | Approx. Headcount | Notes |
|---|---|---|---|---|
| MedDefense Central | Downtown, 350-bed acute care hospital, 6 floors + basement | Emergency, Surgery, Cardiology, Radiology, Oncology, Pediatrics, Maternity, Pharmacy, Laboratory, Administration | ~1,400 (clinical + support) | Basement level houses mechanical/server room per HR guide; underground staff parking, surface visitor lot |
| Westside Clinic | Suburban outpatient facility, 2-story medical office complex, 12 min from Central | Primary care, diagnostic imaging (X-ray, ultrasound — no MRI), blood work, minor procedures, physical therapy | ~180 | Shares some IT services with Central but has its own local server closet for "basic needs" (Sarah Park); shares parking with an adjacent retail plaza |
| Corporate HQ | Leased office space, Greenfield Business Park, 3rd floor of a 5-story building, 15 min from Central | Finance, HR, Legal, Marketing, Executive Leadership, IT | ~220 | No on-premise servers — staff use cloud services and connect to Central's infrastructure via site-to-site VPN; the 12-person IT department is physically based here |

Total organization-wide headcount: **~2,000**.

**Departments/functions relevant to security:** Clinical departments (per Central's list above), Finance/Billing, Legal, HR, Marketing, IT (12 staff total, based at Corporate HQ, led by Sarah Park), and Security (currently one position: the Security Analyst, reporting to James Chen).

**Reporting structure relevant to security** (per org chart):

```
CEO: Dr. Patricia Morales
 ├─ CFO: Robert Kim
 ├─ COO: Angela Torres → Clinical Directors (per department)
 ├─ General Counsel: David Park
 └─ CISO (vacant) — James Chen acts as Deputy CISO
      ├─ James Chen, Deputy CISO
      │    └─ Security Analyst (this role; replacing Marcus Webb)
      └─ Sarah Park, IT Director
           ├─ 3x System Administrators
           ├─ 2x Network Technicians
           ├─ 1x Database Administrator
           ├─ 2x Helpdesk Analysts (incl. Mike Torres, lead)
           ├─ 2x Desktop Support Technicians
           └─ 1x IT Intern (position currently vacant)
```

**Structural note directly relevant to security posture:** James Chen formally reports to a vacant CISO position and in practice reports to the CEO directly. Sarah Park (IT Director) and James Chen (Deputy CISO) are **organizational peers**, not a reporting relationship — James has authority over security *policy* but no authority over IT *operations*. This structural friction is the most plausible explanation for why security findings escalated to Sarah Park's team (the server room badge issue, the backup NAS placement, the flat network) have gone unactioned for months: James can recommend, but cannot compel IT to implement.

## 2. IT Infrastructure Identified

### Servers — MedDefense Central

| Name | OS/Platform | Function | Notes |
|---|---|---|---|
| `ehr-srv-01` | Ubuntu 20.04 LTS | EHR application server | — |
| `ehr-db-01` | Ubuntu 20.04 LTS | EHR database (PostgreSQL) | PostgreSQL reachable from the **entire** `10.10.0.0/16` range per Marcus's notes — should be restricted to `ehr-srv-01` only |
| `pacs-srv-01` | Windows Server 2016 | PACS imaging server | Receives studies from the MRI and other imaging modalities |
| `billing-srv-01` | Ubuntu 18.04 LTS | Billing/claims processing | Chronic "performance issues," IT restarts rather than investigates; separately confirmed by root-cause analysis to be an active cryptomining compromise, not a hardware issue |
| `ad-dc-01` / `ad-dc-02` | Windows Server 2019 | Primary/secondary domain controllers | — |
| `file-srv-01` | Windows Server 2016 | Department file shares | Includes HR file share |
| `print-srv-01` | Windows Server 2012 R2 | Print server | **[UNVERIFIED]** in ticketing; end-of-support since Oct 2023, no remediation plan noted |
| `backup-srv-01` | Ubuntu 22.04 LTS | Backup server (Veeam agent) | Backs up nightly to a local NAS in the **same server room, same network, same rack** as the production servers it protects — a single ransomware event could destroy both simultaneously; Marcus raised offsite/cloud backup with James, budget was denied |
| `web-srv-01` | Ubuntu 20.04 LTS | Public website + patient portal | Sits in the DMZ per the network diagram, directly behind the FortiGate |

### Servers — Westside Clinic

| Name | OS/Platform | Function | Notes |
|---|---|---|---|
| `ws-srv-01` | Windows Server 2016 | Local file server + scheduling | — |
| *Unconfirmed second server* | Unknown | Unknown | Marcus's note: Mike Torres mentioned a possible second server in the Westside closet; never physically confirmed — **open item, see Known Unknowns** |

### Servers — Corporate HQ

None on-premise. HQ staff use cloud services (O365) and reach Central's infrastructure over a site-to-site VPN via the building-managed network.

### Network Equipment

| Site | Equipment |
|---|---|
| Central | Cisco core switch (model unknown); 2x Cisco access switches per floor; 1x Fortinet FortiGate 100F firewall; 12x Ubiquiti UniFi wireless APs |
| Westside | 1x unmanaged switch (unknown brand); 1x **consumer-grade Netgear Nighthawk router** — this router also carries the site-to-site IPSec VPN to Central; **no firewall exists at this site** |
| Corporate HQ | Network managed by the building landlord; MedDefense has its own VLAN on that shared infrastructure; site-to-site VPN to Central |

### Endpoints

| Location | Count/Type |
|---|---|
| Central | ~320 Windows 10 workstations; ~60 thin clients in clinical areas |
| Westside | ~45 Windows 10 workstations |
| Corporate HQ | ~120 Windows 10/11 workstations; ~30 remote-capable laptops |
| Org-wide | ~25 iPads used by physicians for rounds (management/MDM status unclear) |

Per Marcus's notes, these counts derive from an Active Directory report **8 months old** — no source has a current, complete endpoint count.

### Medical Devices (IoT)

| Device | Count/Model | Location | Notes |
|---|---|---|---|
| Connected patient monitors | ~80 units, Philips IntelliVue | Central | Same flat network as workstations and servers (see Network section, Section 4) |
| Infusion pumps | ~120 units, BD Alaris | Central | Network-connected for dosage updates — Marcus flagged that anyone reaching the network can reach the pumps |
| MRI scanner | 1x Siemens MAGNETOM | Radiology, Central | Runs Windows XP; manufacturer-locked OS (see Task 6 compensating-control case) |
| CT scanner | 1x GE Revolution | Central | OS unknown/unconfirmed |
| Nurse call system | IP-based | Central (implied org-wide) | Integrated with the phone system |
| Badge/access system | HID Global | Central (at least partial coverage) | Connected to Active Directory for **some** doors only — coverage is not universal |

### Network Topology (per Marcus's draft diagram)

```
[INTERNET] → [FortiGate 100F] → DMZ: web-srv-01
                    ↓
              [Core Switch]
                    ↓
    ┌───────┬───────┬───────┬────────┐
   Flr1    Flr2    Flr3    Flr4    Servers
  (APs, workstations, thin clients,   (ehr-srv-01, ehr-db-01, pacs-srv-01,
   medical devices, monitors, pumps)   billing-srv-01, ad-dc-01/02, file-srv-01,
                                       print-srv-01, backup-srv-01 → NAS)

Everything on 10.10.0.0/16 — no VLANs configured anywhere at Central.

Westside Clinic --- IPSec VPN --> FortiGate (via the Netgear consumer router)
Corporate HQ    --- Site-to-site VPN --> FortiGate (via building-managed network)
```

Marcus's own note on this diagram: it is simplified and the real topology is "messier" — it should be treated as directional, not authoritative.

## 3. Data and Services

**Data types handled by MedDefense:**
- Protected Health Information (PHI): medical histories, lab results, prescriptions, imaging studies, real-time vitals and infusion data
- Financial/billing data: insurance claims, payment information
- Employee/HR records (on `file-srv-01`)
- System credentials, including at least one confirmed **shared account** (Radiology's PACS login, `raduser`/`radiology1`)
- Cloud service data: Microsoft O365 (org-wide, confirmed); Marcus suspected but never confirmed additional, unsanctioned departmental cloud services

**Critical services dependent on IT infrastructure:**
- Electronic health records access (`ehr-srv-01`/`ehr-db-01`) — physicians and nurses, direct patient care
- Diagnostic imaging capture and archival (`pacs-srv-01`, MRI, CT) — radiology, patient diagnosis
- Insurance claims processing/billing (`billing-srv-01`) — finance, revenue cycle
- Real-time patient monitoring and infusion dosing (Philips monitors, BD Alaris pumps) — clinical staff, direct patient safety, and now confirmed to sit on the same unsegmented network as everything else
- Identity and access (`ad-dc-01/02`) — underpins authentication for the entire organization
- Patient self-service (`web-srv-01`) — patients, at all sites
- Backup/recovery (`backup-srv-01` + NAS) — organization-wide, but itself a single point of failure per Marcus's notes

**Users:** Clinical staff across all departments, finance/billing staff, IT staff (12, at HQ), patients, and the general public (public website).

## 4. Known Unknowns

- **Whether a second server exists in the Westside network closet.** Marcus flagged this directly ("check") and never confirmed it — this needs physical verification before any Westside-specific risk assessment is finalized.
- **Whether guest WiFi at Central is actually isolated from the internal network.** Marcus explicitly noted the SSID exists but he was "not convinced" of real isolation and never verified it — this is a materially important unknown given Incident F (the intern's device sitting on the *internal*, not guest, network for three weeks).
- **HQ VPN ACLs have never been audited.** Marcus noted the configuration "seems" correct but explicitly had not reviewed the access control rules.
- **iPad management/MDM status is unconfirmed** — ~25 devices used by physicians for rounds, unclear whether they are enrolled in any mobile device management program.
- **CT scanner OS is unknown**, unlike the MRI, which is confirmed Windows XP. Given the MRI finding, the CT scanner's OS should be treated as a priority item to verify, not assumed to be safe by omission.
- **HID badge/AD integration is partial** ("some doors") — which doors are and are not integrated, and specifically whether the server room is one of the integrated doors or the unmanaged generic-badge doors described in the physical walk-through, is not confirmed.
- **Whether unsanctioned departmental cloud services exist beyond O365** — Marcus suspected this but ran out of time to inventory it; this is a strong candidate area for additional shadow IT beyond what has already surfaced (Task 11).
- **Discrepancy to flag — server room location.** The HR onboarding guide places Central's "mechanical/server room" in the **basement**. The physical walk-through (Task 3, Observation 1) describes a server room accessed from a **ground-floor** corridor shared with the cafeteria. These may be two different rooms (a basement mechanical/server space plus a separate ground-floor IT server room), or a documentation inconsistency — this should be physically confirmed with Sarah Park's team before finalizing the physical-security findings.
- **Discrepancy to flag — IT department location vs. Task 3's IT-department sighting.** The onboarding packet places the entire 12-person IT department at **Corporate HQ**, but the physical walk-through of Central (Task 3, Observation 5) describes a hallway "leading to the IT department and James Chen's office" visible through a propped fire exit **at Central**. Possible explanations: James Chen may keep a secondary office at Central (plausible, given his security role spans all sites), or there is a small satellite IT presence at Central not captured in the org chart. This needs a direct answer, since it affects how Observation 5's severity should be scoped.
- **Discrepancy to flag — the IT Intern position.** The org chart lists the IT Intern position as **currently vacant**, yet Incident F (June 10) involved an active IT intern's personal laptop on the network, and the Raspberry Pi (Task 11) was reportedly set up by "a previous intern" at Marcus's request. This is consistent with an intern having since departed rather than a contradiction, but the timeline (when exactly the intern left, and whether their access was properly deprovisioned) is unconfirmed and should be checked — an unrevoked account or lingering device from a departed intern is a plausible, low-effort gap given everything else observed in this environment.
- **No formal vulnerability assessment has ever been performed** on any server — confirmed directly by Marcus's notes as unfinished work, not merely undocumented.
- **No confirmation that Sophos endpoint protection is current on all machines** — the contract exists ($18,000/yr) but Marcus explicitly flagged that he did not know its actual deployment/definition status across the endpoint fleet.
- **No HIPAA Security Rule compliance assessment has ever been formally conducted.** Legal's assertion that "we're compliant" has no supporting evidence per Marcus's notes — this is a governance gap distinct from, but compounding, the technical gaps.
- **No incident response plan, business continuity plan, or disaster recovery plan exists in any documented form.** The January ransomware response was improvised in real time by James, Sarah, and Marcus over four days; Central's UPS covers only ~20 minutes of outage with no documented procedure beyond that.
