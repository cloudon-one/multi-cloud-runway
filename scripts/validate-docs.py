#!/usr/bin/env python3
"""
Documentation Validation Script for Multi-Cloud Infrastructure

This script validates documentation consistency and completeness across
the multi-cloud infrastructure repository.
"""

import os
import sys
import re
import yaml
from pathlib import Path
from typing import Dict, List, Set, Tuple
import argparse

class DocumentationValidator:
    def __init__(self, root_dir: str = "."):
        self.root_dir = Path(root_dir)
        self.errors = []
        self.warnings = []
        self.info = []
        
    def validate_all(self) -> bool:
        """Run all documentation validations"""
        print("📚 Running documentation validation...")
        
        # Validate README files
        self.validate_readme_files()
        
        # Validate documentation structure
        self.validate_doc_structure()
        
        # Validate configuration documentation
        self.validate_config_docs()
        
        # Validate links
        self.validate_links()
        
        # Validate YAML documentation
        self.validate_yaml_docs()
        
        # Print results
        self.print_results()
        
        return len(self.errors) == 0
        
    def validate_readme_files(self):
        """Validate README files for completeness"""
        readme_files = list(self.root_dir.rglob("README.md"))
        
        required_sections = {
            "main": [
                "# Multi-Cloud Landing Zone Infrastructure",
                "## Overview", "## Architecture", "## Prerequisites",
                "## Getting Started", "## Support"
            ],
            "aws": [
                "# AWS Landing Zone Infrastructure",
                "## Overview", "## Architecture", "## Services Implemented",
                "## Deployment Guide", "## Security Implementation"
            ],
            "gcp": [
                "# GCP Landing Zone Infrastructure", 
                "## Overview", "## Architecture", "## Services Implemented",
                "## Deployment Guide", "## Security Implementation"
            ]
        }
        
        for readme_file in readme_files:
            self.validate_readme_content(readme_file, required_sections)
            
    def validate_readme_content(self, file_path: Path, required_sections: Dict[str, List[str]]):
        """Validate individual README file content"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            # Determine README type
            readme_type = "main"
            if "aws-terragrunt-configuration" in str(file_path):
                readme_type = "aws"
            elif "gcp-terragrunt-configuration" in str(file_path):
                readme_type = "gcp"
                
            # Check for required sections
            sections = required_sections.get(readme_type, required_sections["main"])
            for section in sections:
                if section not in content:
                    self.warnings.append(f"{file_path}: Missing section '{section}'")
                    
            # Check for broken markdown links
            self.check_markdown_links(file_path, content)
            
            # Check for TOC if file is large
            if len(content.split('\n')) > 100 and "## Table of Contents" not in content:
                self.warnings.append(f"{file_path}: Large README missing Table of Contents")
                
        except Exception as e:
            self.errors.append(f"Error reading {file_path}: {e}")
            
    def validate_doc_structure(self):
        """Validate overall documentation structure"""
        required_docs = [
            "README.md",
            "SECURITY.md", 
            "CONTRIBUTING.md",
            "CLAUDE.md"
        ]
        
        for doc in required_docs:
            doc_path = self.root_dir / doc
            if not doc_path.exists():
                self.errors.append(f"Missing required documentation: {doc}")
            else:
                self.info.append(f"Found required documentation: {doc}")
                
        # Check for environment-specific READMEs
        aws_readme = self.root_dir / "aws-terragrunt-configuration" / "README.md"
        gcp_readme = self.root_dir / "gcp-terragrunt-configuration" / "README.md"
        
        if not aws_readme.exists():
            self.warnings.append("Missing AWS-specific README")
        if not gcp_readme.exists():
            self.warnings.append("Missing GCP-specific README")
            
    def validate_config_docs(self):
        """Validate that configuration changes are documented"""
        # Find all terragrunt.hcl files
        hcl_files = list(self.root_dir.rglob("terragrunt.hcl"))
        
        undocumented_configs = []
        for hcl_file in hcl_files:
            service_dir = hcl_file.parent
            readme_file = service_dir / "README.md"
            
            # Check if there's a service-specific README
            if not readme_file.exists():
                # Check if it's a major service directory
                if any(service in str(service_dir) for service in 
                       ['vpc', 'eks', 'rds', 'gke', 'sql']):
                    undocumented_configs.append(str(service_dir))
                    
        if undocumented_configs:
            self.warnings.append(
                f"Major services without README files: {', '.join(undocumented_configs[:5])}"
            )
            
    def validate_links(self):
        """Validate links in documentation"""
        md_files = list(self.root_dir.rglob("*.md"))
        
        for md_file in md_files:
            try:
                with open(md_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                self.check_markdown_links(md_file, content)
            except Exception as e:
                self.errors.append(f"Error reading {md_file}: {e}")
                
    def check_markdown_links(self, file_path: Path, content: str):
        """Check markdown links for validity"""
        # Find markdown links [text](link)
        link_pattern = r'\[([^\]]*)\]\(([^)]+)\)'
        links = re.findall(link_pattern, content)
        
        for link_text, link_url in links:
            # Skip external URLs (they would need network validation)
            if link_url.startswith(('http://', 'https://', 'mailto:')):
                continue
                
            # Skip anchor links
            if link_url.startswith('#'):
                continue
                
            # Check relative file links
            if not link_url.startswith('/'):
                target_path = (file_path.parent / link_url).resolve()
                if not target_path.exists():
                    self.errors.append(
                        f"{file_path}: Broken link '{link_url}' (target not found)"
                    )
                    
    def validate_yaml_docs(self):
        """Validate YAML file documentation"""
        yaml_files = list(self.root_dir.rglob("*.yaml")) + list(self.root_dir.rglob("*.yml"))
        
        for yaml_file in yaml_files:
            try:
                with open(yaml_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                # Check for inline documentation
                comment_lines = [line for line in content.split('\n') if line.strip().startswith('#')]
                total_lines = len([line for line in content.split('\n') if line.strip()])
                
                if total_lines > 50 and len(comment_lines) < total_lines * 0.1:
                    self.warnings.append(
                        f"{yaml_file}: Large YAML file with insufficient comments"
                    )
                    
                # Validate YAML syntax
                try:
                    yaml.safe_load(content)
                except yaml.YAMLError as e:
                    self.errors.append(f"{yaml_file}: Invalid YAML syntax: {e}")
                    
            except Exception as e:
                self.errors.append(f"Error reading {yaml_file}: {e}")
                
    def validate_code_documentation(self):
        """Validate code documentation in HCL files"""
        hcl_files = list(self.root_dir.rglob("*.hcl"))
        
        for hcl_file in hcl_files:
            try:
                with open(hcl_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                # Check for variable documentation
                if 'variable ' in content:
                    variables = re.findall(r'variable\s+"([^"]+)"', content)
                    for var in variables:
                        var_block_pattern = f'variable\\s+"{re.escape(var)}"\\s*{{[^}}]*}}'
                        var_block = re.search(var_block_pattern, content, re.DOTALL)
                        if var_block and 'description' not in var_block.group():
                            self.warnings.append(
                                f"{hcl_file}: Variable '{var}' lacks description"
                            )
                            
            except Exception as e:
                self.errors.append(f"Error reading {hcl_file}: {e}")
                
    def validate_security_docs(self):
        """Validate security documentation completeness"""
        security_file = self.root_dir / "SECURITY.md"
        if security_file.exists():
            try:
                with open(security_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                required_sections = [
                    "## Security Standards Compliance",
                    "## Reporting Security Issues",
                    "## Security Controls Implementation"
                ]
                
                for section in required_sections:
                    if section not in content:
                        self.warnings.append(f"SECURITY.md: Missing section '{section}'")
                        
            except Exception as e:
                self.errors.append(f"Error reading SECURITY.md: {e}")
        else:
            self.errors.append("Missing SECURITY.md file")
            
    def validate_contributing_docs(self):
        """Validate contributing documentation"""
        contributing_file = self.root_dir / "CONTRIBUTING.md"
        if contributing_file.exists():
            try:
                with open(contributing_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                required_sections = [
                    "## Development Workflow",
                    "## Infrastructure Guidelines", 
                    "## Security Considerations",
                    "## Review Process"
                ]
                
                for section in required_sections:
                    if section not in content:
                        self.warnings.append(f"CONTRIBUTING.md: Missing section '{section}'")
                        
            except Exception as e:
                self.errors.append(f"Error reading CONTRIBUTING.md: {e}")
        else:
            self.errors.append("Missing CONTRIBUTING.md file")
            
    def check_documentation_freshness(self):
        """Check if documentation might be outdated"""
        # Compare modification times of docs vs code
        code_files = list(self.root_dir.rglob("*.hcl")) + list(self.root_dir.rglob("*.yaml"))
        doc_files = list(self.root_dir.rglob("*.md"))
        
        if code_files and doc_files:
            latest_code = max(f.stat().st_mtime for f in code_files)
            latest_doc = max(f.stat().st_mtime for f in doc_files)
            
            # If code is significantly newer than docs (more than 7 days)
            if latest_code - latest_doc > 7 * 24 * 60 * 60:
                self.warnings.append(
                    "Documentation may be outdated - code files modified more recently than docs"
                )
                
    def print_results(self):
        """Print validation results"""
        total_issues = len(self.errors) + len(self.warnings)
        
        print(f"\n📊 Documentation Validation Results:")
        print(f"  Errors: {len(self.errors)}")
        print(f"  Warnings: {len(self.warnings)}")
        print(f"  Info: {len(self.info)}")
        
        if self.errors:
            print(f"\n❌ Errors ({len(self.errors)}):")
            for error in self.errors:
                print(f"  • {error}")
                
        if self.warnings:
            print(f"\n⚠️  Warnings ({len(self.warnings)}):")
            for warning in self.warnings:
                print(f"  • {warning}")
                
        if self.info:
            print(f"\nℹ️  Information ({len(self.info)}):")
            for info in self.info:
                print(f"  • {info}")
                
        if not total_issues:
            print("✅ No documentation issues found!")
        else:
            print(f"\n⚠️  Total issues found: {total_issues}")
            
def main():
    parser = argparse.ArgumentParser(description="Validate documentation in multi-cloud infrastructure")
    parser.add_argument("--root-dir", default=".", help="Root directory to scan (default: current)")
    parser.add_argument("--fail-on-warnings", action="store_true", help="Fail on warnings as well as errors")
    
    args = parser.parse_args()
    
    validator = DocumentationValidator(args.root_dir)
    success = validator.validate_all()
    
    if args.fail_on_warnings and validator.warnings:
        success = False
        
    sys.exit(0 if success else 1)
    
if __name__ == "__main__":
    main()