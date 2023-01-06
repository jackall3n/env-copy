# env-copy

Copies environment variables from a host using SSH

## Setup
```bash
alias ec="sh ./env-copy.sh"
```

## Usage

#### Arguments
```bash
ec -p <PORT> [HOST] --key <OPTIONAL_KEY_PATTERN>
```

#### Decode
```bash
ec -p <PORT> [HOST] --key <OPTIONAL_KEY_PATTERN> --decode
```

#### Example
```bash
ec -p 1234 3.123.234.345 --key SERVICE_KEY --decode
```
