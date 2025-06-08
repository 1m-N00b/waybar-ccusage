# waybar-ccusage

A Waybar widget script that shows how much you'd be paying for Claude Code if you were on a pay-per-use plan.

#### status
![bar image](https://github.com/user-attachments/assets/54dc72bc-a3c0-49d4-a40f-8054e9885538)

#### daily mode
![daily mode](https://github.com/user-attachments/assets/12fb11b9-82ed-4fe0-8910-2009a85be2e1)


#### session mode
![session mode](https://github.com/user-attachments/assets/ee2ee199-d6b7-45d1-87f0-d69952cfdba7)

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
