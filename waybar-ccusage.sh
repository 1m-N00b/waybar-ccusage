#!/bin/bash

set -euo pipefail

# Configuration
readonly DAYS_BACK=7
readonly DATE_FILTER="--since $(date -d "${DAYS_BACK} days ago" +%Y%m%d)"

# Utility functions
format_number() {
    printf "%12d" "$1"
}

format_cost() {
    printf "%8.2f" "$1"
}

extract_data_from_json() {
    local json_data="$1"
    local path="$2"
    echo "$json_data" | jq -r "$path"
}

# Table structure functions
create_daily_table_header() {
    local header=""
    header+="┌──────────────┬──────────────┬──────────────┬──────────────┬──────────────┬──────────────┬────────────┐\n"
    header+="│ Date         │        Input │       Output │ Cache Create │   Cache Read │ Total Tokens │ Cost (USD) │\n"
    header+="├──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼────────────┤"
    echo "$header"
}

create_daily_table_separator() {
    echo "├──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼────────────┤"
}

create_daily_table_footer() {
    echo "└──────────────┴──────────────┴──────────────┴──────────────┴──────────────┴──────────────┴────────────┘"
}

create_session_table_header() {
    local header=""
    header+="┌─────────────────┬─────────────────┬──────────────┬──────────────┬──────────────┬──────────────┬──────────────┬────────────┬───────────────┐\n"
    header+="│ Project         │ Session         │        Input │       Output │ Cache Create │   Cache Read │ Total Tokens │ Cost (USD) │ Last Activity │\n"
    header+="├─────────────────┼─────────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼────────────┼───────────────┤"
    echo "$header"
}

create_session_table_separator() {
    echo "├─────────────────┼─────────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼────────────┼───────────────┤"
}

create_session_table_footer() {
    echo "└─────────────────┴─────────────────┴──────────────┴──────────────┴──────────────┴──────────────┴──────────────┴────────────┴───────────────┘"
}

# Data row generation functions
generate_daily_data_row() {
    local line="$1"
    local date input output cache_create cache_read total cost
    
    date=$(extract_data_from_json "$line" '.date')
    input=$(extract_data_from_json "$line" '.inputTokens')
    output=$(extract_data_from_json "$line" '.outputTokens')
    cache_create=$(extract_data_from_json "$line" '.cacheCreationTokens')
    cache_read=$(extract_data_from_json "$line" '.cacheReadTokens')
    total=$(extract_data_from_json "$line" '.totalTokens')
    cost=$(extract_data_from_json "$line" '.totalCost')
    
    printf "│ %s   │ %s │ %s │ %s │ %s │ %s │ $ %s │\n" \
        "$date" \
        "$(format_number "$input")" \
        "$(format_number "$output")" \
        "$(format_number "$cache_create")" \
        "$(format_number "$cache_read")" \
        "$(format_number "$total")" \
        "$(format_cost "$cost")"
}

generate_session_data_row() {
    local line="$1"
    local project session input output cache_create cache_read total cost last_activity
    
    project=$(extract_data_from_json "$line" '.project')
    session=$(extract_data_from_json "$line" '.session')
    input=$(extract_data_from_json "$line" '.inputTokens')
    output=$(extract_data_from_json "$line" '.outputTokens')
    cache_create=$(extract_data_from_json "$line" '.cacheCreationTokens')
    cache_read=$(extract_data_from_json "$line" '.cacheReadTokens')
    total=$(extract_data_from_json "$line" '.totalTokens')
    cost=$(extract_data_from_json "$line" '.totalCost')
    last_activity=$(extract_data_from_json "$line" '.lastActivity')
    
    printf "│ %-15s │ %-15s │ %s │ %s │ %s │ %s │ %s │ $ %s │ %-13s │\n" \
        "$project" \
        "$session" \
        "$(format_number "$input")" \
        "$(format_number "$output")" \
        "$(format_number "$cache_create")" \
        "$(format_number "$cache_read")" \
        "$(format_number "$total")" \
        "$(format_cost "$cost")" \
        "$last_activity"
}

# Total row generation functions
generate_daily_total_row() {
    local totals="$1"
    local input output cache_create cache_read total cost
    
    input=$(extract_data_from_json "$totals" '.inputTokens')
    output=$(extract_data_from_json "$totals" '.outputTokens')
    cache_create=$(extract_data_from_json "$totals" '.cacheCreationTokens')
    cache_read=$(extract_data_from_json "$totals" '.cacheReadTokens')
    total=$(extract_data_from_json "$totals" '.totalTokens')
    cost=$(extract_data_from_json "$totals" '.totalCost')
    
    printf "│ Total        │ %s │ %s │ %s │ %s │ %s │ $ %s │" \
        "$(format_number "$input")" \
        "$(format_number "$output")" \
        "$(format_number "$cache_create")" \
        "$(format_number "$cache_read")" \
        "$(format_number "$total")" \
        "$(format_cost "$cost")"
}

generate_session_total_row() {
    local totals="$1"
    local input output cache_create cache_read total cost
    
    input=$(extract_data_from_json "$totals" '.inputTokens')
    output=$(extract_data_from_json "$totals" '.outputTokens')
    cache_create=$(extract_data_from_json "$totals" '.cacheCreationTokens')
    cache_read=$(extract_data_from_json "$totals" '.cacheReadTokens')
    total=$(extract_data_from_json "$totals" '.totalTokens')
    cost=$(extract_data_from_json "$totals" '.totalCost')
    
    printf "│ Total           │                 │ %s │ %s │ %s │ %s │ %s │ $ %s │               │" \
        "$(format_number "$input")" \
        "$(format_number "$output")" \
        "$(format_number "$cache_create")" \
        "$(format_number "$cache_read")" \
        "$(format_number "$total")" \
        "$(format_cost "$cost")"
}

# Tooltip generation functions
generate_daily_tooltip() {
    local json_data="$1"
    local tooltip=""
    
    tooltip+="$(create_daily_table_header)\n"
    
    while IFS= read -r line; do
        tooltip+="$(generate_daily_data_row "$line")"
    done < <(echo "$json_data" | jq -c '.daily[]')
    
    tooltip+="$(create_daily_table_separator)\n"
    
    local totals
    totals=$(extract_data_from_json "$json_data" '.totals')
    tooltip+="$(generate_daily_total_row "$totals")"
    
    tooltip+="\n$(create_daily_table_footer)"
    
    echo "$tooltip"
}

generate_session_tooltip() {
    local json_data="$1"
    local tooltip=""
    
    tooltip+="$(create_session_table_header)\n"
    
    while IFS= read -r line; do
        tooltip+="$(generate_session_data_row "$line")"
    done < <(echo "$json_data" | jq -c '.sessions[]')
    
    tooltip+="$(create_session_table_separator)\n"
    
    local totals
    totals=$(extract_data_from_json "$json_data" '.totals')
    tooltip+="$(generate_session_total_row "$totals")"
    
    tooltip+="\n$(create_session_table_footer)"
    
    echo "$tooltip"
}

# Main functions
get_ccusage() {
    local mode="$1"
    local json_data cost tooltip
    
    json_data=$(ccusage "$mode" "$DATE_FILTER" --json)
    
    cost=$(extract_data_from_json "$json_data" '.totals.totalCost')
    
    if [[ "$mode" == "daily" ]]; then
        tooltip=$(generate_daily_tooltip "$json_data")
    else
        tooltip=$(generate_session_tooltip "$json_data")
    fi
    
    printf '{"text": "  %s $%.4f", "tooltip": "%s"}\n' "🤖" "$cost" "$tooltip"
}

main() {
    local mode="${1:-daily}"  # Default to daily mode
    get_ccusage "$mode"
}

# Execute main only when script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
