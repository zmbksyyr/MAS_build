# MAS Automated Build

Automated build pipeline for Microsoft Activation Scripts (MAS).

This repository does not store source code or build artifacts.
All sources are fetched during GitHub Actions runtime and built automatically.

## Features

- Pull latest MAS and TSforge sources
- Build TSforge from source
- Generate customized MAS release package
- Create GitHub Release automatically
- Generate build information and SHA256 checksums

## Usage

Run manually:
GitHub Actions → Build MAS Release → Run workflow


The generated release will contain:

- MAS release package
- Source snapshots
- Build information
- SHA256 checksums

## Sources

- MAS:
  https://github.com/massgravel/Microsoft-Activation-Scripts

- TSforge:
  https://github.com/massgravel/TSforge
