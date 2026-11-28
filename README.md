# ToutMX — canal `stable`

Version **0.2.0**. Panel auto-hébergé pour administrer une architecture mail professionnelle.

Ce dépôt ne contient que les versions compilées. Site : https://toutmx.com — documentation : https://docs.toutmx.com

## Installation

```bash
curl -fsSL https://toutmx.com/install.sh | sudo sh
```

Puis ouvrez `https://<serveur>:9543` : l'assistant d'installation démarre.

Systèmes : Debian 12 et 13, Ubuntu 22.04 et 24.04, AlmaLinux et Rocky Linux 9 et 10. Architectures : amd64, arm64.

## Fichiers

| Fichier | Rôle |
|---|---|
| `toutmx-linux-amd64.tar.gz`, `toutmx-linux-arm64.tar.gz` | Binaires `toutmx` et `toutmx-engine`, service systemd, exemple de configuration |
| `SHA256SUMS` | Sommes de contrôle, vérifiées par le script d'installation |
| `manifest.json` | Version, date et empreintes de ce canal |
| `install.sh` | Script d'installation |

Vérification manuelle : `sha256sum -c SHA256SUMS`.
