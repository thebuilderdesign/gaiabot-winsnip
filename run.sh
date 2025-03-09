#!/bin/bash

# Konfigurasi
URL="https://NodeIdmu.gaia.domains/v1/chat/completions"
HEADERS=(-H "accept: application/json" -H "Content-Type: application/json")
KEYWORDS_FILE="keywords.txt"
INTERVAL=30 # Interval dalam detik

# Warna
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

# Cek apakah jq terinstal
if ! command -v jq &>/dev/null; then
  echo -e "${RED}Error: 'jq' tidak ditemukan! Silakan install dengan 'sudo apt install jq' atau 'sudo yum install jq'.${RESET}"
  exit 1
fi

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

  # Cek koneksi internet sebelum mengirim request
  if ! ping -c 1 8.8.8.8 &>/dev/null; then
    echo -e "${RED}Error: Tidak ada koneksi internet!${RESET}"
    return
  fi

  # Mengirim request menggunakan curl
  response=$(curl -s -X POST "$URL" "${HEADERS[@]}" -d "$data")

  # Cek apakah respons valid
  if ! echo "$response" | jq -e . >/dev/null 2>&1; then
    echo -e "${RED}Error: Respons tidak valid!${RESET}"
    return
  fi

  # Mengekstrak konten dari respons
  local content=$(echo "$response" | jq -r '.choices[0].message.content // "Tidak ada respons."')

  echo -e "${GREEN}Response diterima:${RESET}"
  echo -e "${CYAN}$content${RESET}"
  echo -e "${YELLOW}------------------------------------${RESET}"
}

# Menangani SIGINT (Ctrl+C) untuk keluar dengan rapi
trap "echo -e '${RED}\nScript dihentikan oleh pengguna.${RESET}'; exit 0" SIGINT

# Loop untuk mengirim request setiap INTERVAL detik
while true; do
  send_request
  echo -e "${GREEN}Menunggu $INTERVAL detik sebelum request berikutnya...${RESET}"
  sleep $INTERVAL
done
