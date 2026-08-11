# Board Briefing — MedDefense Security Posture

Our review found that MedDefense's entire hospital network — patient monitors, infusion pumps, billing, and patient records — runs as one single, unprotected space. If an attacker gets into any one device, nothing stops them from reaching everything else. That gap has already cost us: our billing server was hit by ransomware in January, and while investigating unrelated performance complaints, we discovered it had been secretly hijacked again, this time to mine cryptocurrency, for weeks, without anyone knowing.

The single most dangerous gap: a second login step for account security exists on exactly one employee's account in our entire organization. Every other password, if stolen, is enough on its own to reach patient records, billing data, or our network core — the exact way most hospital ransomware attacks start.

Our three priority actions, in order:
1. **Require a second login step everywhere**, not just one account. Cost: about $8,000. Timeline: one month.
2. **Close two no-cost exposures**: patient records left visible on unattended screens, and a patient database reachable from any device on our network. Cost: under $1,000. Timeline: this week.
3. **Build basic alerting** so we're notified within hours, not weeks, when something like the cryptomining incident happens again. Cost: about $40,000. Timeline: one to three months.

Total investment: roughly $81,000 of the $120,000 approved budget. This is an investment, not an expense: a single day of billing downtime, like the four days we lost in January, already costs far more than most of this year's proposed budget.

If we take no action, the most likely outcome is a repeat of what already happened, at greater scale and for longer, before anyone notices.
