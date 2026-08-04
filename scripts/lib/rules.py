"""Compliance rules as data (G1-1).

Rule IDs are preserved verbatim from the legacy scripts/compliance-check.py —
do not renumber. New rules append; they never reuse an existing ID.

Each rule: id, framework, title, description, severity, category.
Controls mapping: the id IS the control reference.
"""

FRAMEWORKS = {
    "PCI_DSS": "PCI DSS",
    "CIS": "CIS Benchmarks",
    "SOC2": "SOC 2",
    "ISO27001": "ISO 27001",
    "NIST": "NIST Framework",
}

RULES = [
    # --- PCI DSS (legacy IDs, preserved) ---
    {"id": "PCI-DSS-1.1", "framework": "PCI DSS", "title": "Network Segmentation",
     "description": "Implement network segmentation to isolate cardholder data",
     "severity": "critical", "category": "network"},
    {"id": "PCI-DSS-3.4", "framework": "PCI DSS", "title": "Encryption at Rest",
     "description": "Encrypt cardholder data at rest using strong cryptography",
     "severity": "critical", "category": "encryption"},
    {"id": "PCI-DSS-4.1", "framework": "PCI DSS", "title": "Encryption in Transit",
     "description": "Encrypt cardholder data during transmission over networks",
     "severity": "critical", "category": "encryption"},
    {"id": "PCI-DSS-8.1", "framework": "PCI DSS", "title": "User Authentication",
     "description": "Implement multi-factor authentication for admin access",
     "severity": "high", "category": "access"},
    {"id": "PCI-DSS-10.1", "framework": "PCI DSS", "title": "Audit Logging",
     "description": "Log all access to cardholder data and system components",
     "severity": "high", "category": "logging"},
    # --- CIS Benchmarks (legacy IDs, preserved) ---
    {"id": "CIS-1.1", "framework": "CIS Benchmarks", "title": "Root Access Restriction",
     "description": "Restrict root/admin access to systems",
     "severity": "high", "category": "access"},
    {"id": "CIS-2.1", "framework": "CIS Benchmarks", "title": "Encryption Standards",
     "description": "Use approved encryption algorithms and key lengths",
     "severity": "high", "category": "encryption"},
    {"id": "CIS-3.1", "framework": "CIS Benchmarks", "title": "Network Security",
     "description": "Configure firewalls and network security groups",
     "severity": "medium", "category": "network"},
    {"id": "CIS-5.1", "framework": "CIS Benchmarks", "title": "Logging and Monitoring",
     "description": "Enable comprehensive logging and monitoring",
     "severity": "medium", "category": "logging"},
    # --- SOC 2 (legacy IDs, preserved) ---
    {"id": "SOC2-CC6.1", "framework": "SOC 2", "title": "Logical Access Controls",
     "description": "Implement logical access controls for systems",
     "severity": "high", "category": "access"},
    {"id": "SOC2-CC6.7", "framework": "SOC 2", "title": "Data Transmission Security",
     "description": "Secure data transmission between systems",
     "severity": "high", "category": "encryption"},
    {"id": "SOC2-CC7.1", "framework": "SOC 2", "title": "System Monitoring",
     "description": "Monitor system operations and performance",
     "severity": "medium", "category": "logging"},
]


def rules_for(framework: str):
    return [r for r in RULES if r["framework"] == framework]


def rule(rule_id: str):
    for r in RULES:
        if r["id"] == rule_id:
            return r
    raise KeyError(rule_id)
