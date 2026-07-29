# Physical Walk-Through — Risk Decomposition

## Observation 1: Server Room Access

```
Vulnerability: The server room uses a generic all-employee badge (not a role-restricted credential), has no camera coverage on the door, and no visitor log — any of the ~2,000 staff, or anyone who acquires/borrows a badge, can enter undetected and unrecorded.
Threat: A disgruntled employee, a custodial worker with no operational need for access, or an external party who obtains a badge (theft, tailgating, social engineering) enters the server room unsupervised and unrecorded.
Impact: Physical tampering with, theft of, or unauthorized connection to core servers (including billing-srv-01, which has already been compromised twice) — potential impact to Confidentiality (direct data access), Integrity (physical tampering with hardware/data), and Availability (theft or sabotage of equipment).
Severity: Critical — this room houses the organization's most sensitive infrastructure, there is zero accountability for who enters, and the corridor is shared with a high-traffic public area (the cafeteria).
```

## Observation 2: Network Closet

```
Vulnerability: The network closet housing core switches and patch panels has no functioning lock (door ajar) and displays a laminated sheet with valid switch-management credentials in plain view.
Threat: Any individual with casual physical access to the second floor — an employee, contractor, or unescorted visitor — walks in, reads the credentials, and gains administrative access to core network switching infrastructure.
Impact: An attacker with switch management access can reconfigure VLANs, mirror traffic for eavesdropping, or disable ports — a direct threat to Confidentiality (traffic interception), Integrity (network reconfiguration), and Availability (disabling connectivity hospital-wide).
Severity: Critical — this is not just physical exposure but a fully unlocked path to administrative control of the network core, requiring no technical skill beyond reading a sign.
```

## Observation 3: Nurse Station

```
Vulnerability: An EHR session displaying a patient's record was left unattended and idle for 15+ minutes with no automatic session timeout, and a posted sign actively discourages logging out between shifts.
Threat: Any passerby — another patient, a visitor, a family member, or staff without a legitimate need to view that specific record — reads or photographs the exposed patient data, or acts on the open session.
Impact: Direct, unauthorized disclosure of Protected Health Information to an unauthenticated observer — a Confidentiality violation; a malicious actor could also alter the record while the session is open (Integrity).
Severity: High — this is an active, ongoing exposure rather than a hypothetical one, though it requires physical presence at the exact moment to exploit, and it is one workstation rather than infrastructure-wide.
```

## Observation 4: Medical IoT (Vital Signs Monitor)

```
Vulnerability: A connected vital signs monitor runs firmware last updated in 2019, openly displays its IP address, and shares the same network subnet as nurse-station workstations rather than being isolated on a dedicated medical-device segment.
Threat: An attacker who compromises any device on that shared subnet (e.g., via the nurse-station workstation, or a compromised device elsewhere on the same range) can pivot laterally to reach and potentially manipulate the monitor's readings or use it as a foothold into clinical systems.
Impact: Manipulated vital-sign readings directly threaten patient safety (Integrity with a life-safety consequence); the device can also serve as a persistent, hard-to-patch pivot point into the broader clinical network (Availability/Confidentiality of everything else on that subnet).
Severity: Critical — this is a life-safety device with a 6+ year-old, unpatched firmware baseline, on a shared network with no apparent segmentation.
```

## Observation 5: Emergency Exit

```
Vulnerability: A fire exit door connecting the public waiting area directly to the restricted administrative wing (including the IT department and James Chen's office) is permanently propped open with a physical wedge, defeating whatever access control the door was meant to provide.
Threat: Any member of the public in the waiting area walks through the propped door into the administrative wing, gaining direct physical proximity to IT staff workstations, network infrastructure, and executive offices without ever presenting a badge.
Impact: Physical access to IT and executive areas enables device theft, shoulder-surfing, unauthorized device connection, or social engineering against staff who assume the wing is access-controlled — a Confidentiality and Integrity risk to whatever is reachable from that hallway, and by extension to the assets in Observations 1 and 2.
Severity: High — it fully bypasses the facility's access control model for a public-to-restricted boundary, though it requires someone to notice and exploit the opportunity rather than being a standing digital foothold.
```
