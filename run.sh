#!/bin/bash

# Konfigurasi
URL="https://NodeId.gaia.domains/v1/chat/completions"
HEADERS=(-H "accept: application/json" -H "Content-Type: application/json")
KEYWORDS_FILE="keywords.txt"
INTERVAL=30 # Interval dalam detik

# Warna
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

# Fungsi untuk membaca file kata kunci dan memilih secara acak
get_random_keyword() {
  if [[ -f "$KEYWORDS_FILE" ]]; then
    shuf -n 1 "$KEYWORDS_FILE"
  else
    echo -e "${RED}Error: File $KEYWORDS_FILE tidak ditemukan!${RESET}" >&2
    exit 1
  fi
}

# Fungsi untuk mengirim request
send_request() {
  local keyword=$(get_random_keyword)
  echo -e "${CYAN}Mengirim request dengan kata kunci:${RESET} ${YELLOW}$keyword${RESET}"

  local data=$(cat <<EOF
{
  "messages": [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "$keyword"}
  ]
}
EOF
)

  # Mengirim request menggunakan curl
  response=$(curl -s -X POST "$URL" "${HEADERS[@]}" -d "$data")

  # Mengekstrak konten penting dari respons
  local content=$(echo "$response" | jq -r '.choices[0].message.content')

  echo -e "${GREEN}Response diterima:${RESET}"
  echo -e "${CYAN}$content${RESET}"
  echo -e "${YELLOW}------------------------------------${RESET}"
}

# Loop untuk mengirim request setiap 30 detik
while true; do
  send_request
  echo -e "${GREEN}Menunggu $INTERVAL detik sebelum request berikutnya...${RESET}"
  sleep $INTERVAL
done
