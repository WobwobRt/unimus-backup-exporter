# Unimus Backup Exporter for Docker

**Unimus Backup Exporter** for **Docker** enables you to write your backups you made with Unimus in Docker to git or (any) mounted filesystem.

See https://github.com/netcore-jsa/unimus-backup-exporter for the user manual.

Configuration can be done with the setting names mentioned here, but in ALL CAPS as environment variables. For example: `UNIMUS_SERVER_ADDRESS`. Alternatively, you can use files, for example: `UNIMUS_SERVER_ADDRESS_FILE`. 

## Example docker compose

### With API key in environment variable
```
services:
  exporter:
    image: wobwobrt/unimus-backup-exporter:latest
    environment:
      UNIMUS_SERVER_ADDRESS: "https://unimus.example.com"
      CRON_SCHEDULE: "0 22 * * *"
      BACKUP_TYPE: "all"
      EXPORT_TYPE: "fs"
      UNIMUS_API_KEY: "[get this from you unimus instance -> User management -> API tokens]"
    volumes:
      - ./backups:/exporter/backups
```
