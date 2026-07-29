# Incident Classification — CIA Triad Analysis

## Incident A — Ransomware on `billing-srv-01` (Jan 15)

- **Primary pillar: Availability.** The ransomware encrypted the billing server, making it and its data unusable, and finance could not process insurance claims for 4 days — a direct denial of a service that was needed.
- **Secondary pillar: Integrity.** Encryption by an unauthorized third party is itself an unauthorized modification of the data; additionally, the fact that the backup was 3 weeks old due to a misconfigured cron job means the *integrity of the recovery process itself* was compromised, extending the availability impact.

## Incident B — Patient Portal IDOR (Feb 2)

- **Primary pillar: Confidentiality.** A broken access control allowed any authenticated patient to view other patients' lab results by manipulating a URL parameter — data was exposed to people who should never have seen it.
- **Secondary pillar:** None significant. The system remained available and no data was altered; this is a clean confidentiality violation (an Insecure Direct Object Reference).

## Incident C — Pharmacy Dosage Display Error (Mar 18)

- **Primary pillar: Integrity.** A database update script bug overwrote dosage values, meaning the data displayed no longer reflected the correct, authoritative values — a corruption of data accuracy, not an access or availability issue.
- **Secondary pillar: Availability (partial/practical).** Although the system remained technically online, incorrect dosage data is functionally equivalent to the service being unusable for its intended clinical purpose during those 6 hours, since staff could not safely rely on it.

## Incident D — Website Defacement (Apr 5)

- **Primary pillar: Integrity.** The homepage content was altered without authorization, replacing legitimate content with a political message — a direct, visible modification of a system's data/content.
- **Secondary pillar: Availability (brief).** The legitimate site content was effectively unavailable to visitors during the defacement window, though restoration within 2 hours limited this impact. No confidentiality impact, since the site holds no patient data.

## Incident E — EHR Migration Outage (May 22)

- **Primary pillar: Availability.** A 9-hour outage during a database migration meant physicians could not access the EHR system when needed and reverted to paper records — a direct loss of access to a critical service.
- **Secondary pillar:** None significant as an incident of compromise — this was an operational/change-management failure (untested rollback) rather than a confidentiality or integrity event. It is nonetheless a security-relevant finding because it demonstrates the organization lacks tested continuity procedures for its most critical system.

## Incident F — IT Intern's Unauthorized Device on Internal Network (Jun 10)

- **Primary pillar: Confidentiality.** A personally owned, unmanaged laptop running a torrent client had 3 weeks of unauthorized presence on the internal network segment shared with the HR file share, creating direct exposure risk for employee records to an uncontrolled device and any software running on it.
- **Secondary pillar: Availability/Integrity (risk, not confirmed impact).** A torrent client consuming bandwidth and running unvetted software on the internal segment could degrade network performance (Availability) and represents an unmonitored foothold from which the segment's data could later be altered (Integrity) — the incident is notable less for what happened and more for what it reveals: 3 weeks of undetected presence on the wrong network segment.

## Incident Classification Table

| Incident | Date | Primary Pillar | Justification | Secondary Pillar | Connection |
|---|---|---|---|---|---|
| A — Ransomware on billing-srv-01 | Jan 15 | Availability | Server encrypted; billing unusable for 4 days | Integrity | Backup itself was stale/unreliable, compounding the availability failure |
| B — Patient portal IDOR | Feb 2 | Confidentiality | Patients viewed other patients' lab results via broken access control | — | None significant; pure unauthorized-access event |
| C — Pharmacy dosage error | Mar 18 | Integrity | Update script overwrote dosage values, corrupting displayed data | Availability | Data was untrustworthy, making the system functionally unusable for its clinical purpose |
| D — Website defacement | Apr 5 | Integrity | Homepage content altered without authorization | Availability | Legitimate content unreachable during the defacement window |
| E — EHR migration outage | May 22 | Availability | 9-hour outage forced a return to paper records | — | None significant; a continuity/change-management failure, not a compromise |
| F — Intern's unmanaged laptop on internal network | Jun 10 | Confidentiality | Unmanaged device present 3 weeks on the segment hosting the HR file share | Availability / Integrity | Bandwidth and unvetted software on a sensitive segment create latent risk to both pillars |
