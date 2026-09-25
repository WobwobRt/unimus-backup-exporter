# Unimus Backup Exporter for Docker

**Unimus Backup Exporter** for **Docker** enables you to write your backups you made with Unimus in Docker to git or (any) mounted filesystem.

See https://github.com/netcore-jsa/unimus-backup-exporter for the user manual.

Configuration can be done with the setting names mentioned here, but in ALL CAPS as environment variables. For example: `UNIMUS_SERVER_ADDRESS`.

**NOTE** The API key can be referenced using a docker secret instead of an env-var. Configure `unimus_api_key` secret to replace the env-var. 

## Example docker compose

### With API key in environment variable
```
services:
  exporter:
    image: wobwobrt/unimus-backup-exporter:latest
    environment:
      UNIMUS_SERVER_ADDRESS: "https://unimus.example.com"
      BACKUP_TYPE: "latest"
      EXPORT_TYPE: "fs"
      EXPORT_INTERVAL: "86400"
      UNIMUS_API_KEY: "[get this from you unimus instance -> User management -> API tokens]"
    volumes:
      - ./backups:/exporter/backups
```

### With API key in secret
```
services:
  ube:
    image: wobwobrt/unimus-backup-exporter:latest
    environment:
      UNIMUS_SERVER_ADDRESS: "https://unimus.example.com"
      BACKUP_TYPE: "latest"
      EXPORT_TYPE: "fs"
      EXPORT_INTERVAL: "86400"
    secrets:
      - unimus_api_key
    volumes:
      - ./backups:/exporter/backups
```
