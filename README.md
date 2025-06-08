# waybar-ccusage

A Waybar widget script that shows how much you'd be paying for Claude Code if you were on a pay-per-use plan.

## Dependencies

- [ccusage](https://github.com/ryoppippi/ccusage)
- `jq`

## Configuration

```bash
./waybar-ccusage.sh [mode]
```

Where `mode` can be:
- `daily` (default) - Shows daily usage breakdown for past 7 days
- `session` - Shows session-based usage breakdown for past 7 days

> **Note**: The 7 days(default) period can be customized by modifying the `DAYS_BACK` constant in the script.

## Module

```json
"custom/ccusage": {
    "format": "{}",
    "exec": "~/your-path/waybar-ccusage/waybar-ccusage.sh daily",
    "return-type": "json",
    "tooltip": true,
    "interval": 5,
}
```