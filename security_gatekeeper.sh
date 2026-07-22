#!/usr/bin/env bash

# ==============================================================================
# Script Name:    security_gatekeeper.sh
# Description:    Pre-Deployment Security Scanner for Detecting Hardcoded Secrets
# Author:         Niharika (niharika-bin)
# Architecture:   Lightweight Bash-based security auditing tool using native POSIX utilities
# ==============================================================================

# Create log directory
mkdir -p ./.gatekeeper_logs

LOG_FILE="./.gatekeeper_logs/security_scan_$(date +%Y%m%d_%H%M%S).log"

# Save terminal output and logs together
exec > >(tee -a "$LOG_FILE") 2>&1


echo "========================================================"
echo "              SECURITY GATEKEEPER STARTING"
echo "========================================================"
echo "Scanning workspace for exposed secrets, tokens, and credentials..."
echo "--------------------------------------------------------"


REJECT=0
TOTAL_FILES=0


# Scan every regular file in the workspace
while IFS= read -r file; do

    [[ -f "$file" ]] || continue


    # Skip unnecessary directories
    if [[ "$file" == *"/.git/"* ||
          "$file" == *"/.gatekeeper_logs/"* ||
          "$file" == *"/node_modules/"* ]]; then
        continue
    fi


    ((TOTAL_FILES++))

    line_num=0


    # Read file line by line
    while IFS= read -r line; do

        ((line_num++))


        # ------------------------------------------------
        # 1. Detect Google Gemini API Keys
        # ------------------------------------------------
        if [[ "$line" =~ AIzaSy[A-Za-z0-9_-]{35} ]]; then

            echo "[CRITICAL] Gemini API Key detected"
            echo "File: $file | Line: $line_num"

            REJECT=1
        fi



        # ------------------------------------------------
        # 2. Detect AWS Secret Access Keys
        # ------------------------------------------------
        if [[ "$line" =~ AWS_SECRET_ACCESS_KEY[[:space:]]*=[[:space:]]*['\"]?[A-Za-z0-9/+=]{40} ]]; then

            echo "[CRITICAL] AWS Secret Access Key detected"
            echo "File: $file | Line: $line_num"

            REJECT=1
        fi



        # ------------------------------------------------
        # 3. Detect GitHub Personal Access Tokens
        # ------------------------------------------------
        
        if [[ "$line" =~ ghp_[A-Za-z0-9]{36} ]]; then

            echo "[CRITICAL] GitHub Personal Access Token detected"
            echo "File: $file | Line: $line_num"

            REJECT=1
        fi



        # ------------------------------------------------
        # 4. Detect Hardcoded Bearer Tokens
        # ------------------------------------------------
        if [[ "$line" =~ [Bb]earer[[:space:]]+[A-Za-z0-9._~+/-]+=* ]]; then

            if [[ ! "$line" =~ getenv &&
                  ! "$line" =~ environ &&
                  ! "$line" =~ process.env ]]; then

                echo "[HIGH] Hardcoded Authorization Token detected"
                echo "File: $file | Line: $line_num"

                REJECT=1
            fi
        fi



        # ------------------------------------------------
        # 5. Detect Hardcoded Passwords and Secrets
        # ------------------------------------------------
        if [[ "$line" =~ password|PASSWORD|secret|SECRET|private_key|PRIVATE_KEY ]]; then


            # Ignore secure environment variable usage
            if [[ ! "$line" =~ getenv &&
                  ! "$line" =~ environ &&
                  ! "$line" =~ process.env &&
                  ! "$line" =~ secretmanager &&
                  ! "$line" =~ vault ]]; then


                echo "[WARNING] Possible hardcoded credential detected"
                echo "File: $file | Line: $line_num"

                REJECT=1

            fi

        fi


    done < "$file"


done < <(find . -type f 2>/dev/null)



echo "--------------------------------------------------------"
echo "Scan completed."
echo "Files scanned: $TOTAL_FILES"

echo "Report saved at:"
echo "$LOG_FILE"

echo "--------------------------------------------------------"



# Final security decision

if [ "$REJECT" -eq 1 ]; then

    echo "RESULT: FAILED"
    echo "Security risks detected. Review and remove exposed credentials before deployment."

    exit 1

else

    echo "RESULT: PASSED"
    echo "No exposed credentials detected."

    exit 0

fi