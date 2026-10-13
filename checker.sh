#!/bin/bash

# Список программ для проверки
packages=(
    "vi"
    "man-pages"
    "cheese"
    "testdisk"
    "wipefreespace"
    "newt"
    "pesign"
    "ntfsprogs"
    "btrfs-progs"
    "traceroute"
    "net-tools"
    "tree"
    "NetworkManager-tui"
    "lsof"
    "strace"
    "plocate"
    "inxi"
    "lshw"
    "smartmontools"
    "GIMP"
    "heif-pixbuf-loader"
    "blueman"
    "blueman-nemo"
    "samba-client"
    "Brasero"
    "xsane"
    "hardinfo2"
    "flameshot"
    "remmina"
    "ntfs-3g"
    "samba-common-tools"
    "system-config-printer"
    "kazam"
    "bash-completion"
    "Yandex Browser"
    "ca-certificates-ru"
    "gostsum"
    "hplip"
    "unrar"
    "openssl-gost-engine"
    "mc"
    "nano"
    "wget"
    "7zip"
    "htop"
    "onboard"
    "libreoffice"
    "vlc"
    "gparted"
    "atril"
    "sane-airscan"
    "openvpn"
    "NetworkManager-openvpn"
    "NetworkManager-openvpn-gnome"
    "nemo-mail-plugin"
    "pdfjam"
    "freerdp"
    "exfat"
    "man-db"
    "gnome-screenshot"
    "cifs-utils"
    "keyutils"
    "perl-JSON"
    "numlockx"
    "oddjob"
    "oddjob-mkhomedir"
    "sssd"
    "adcli"
)

# Цвета
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# Функция для получения фактического имени пакета
resolve_pkg_name() {
    local prog="$1"
    case "$prog" in
        "vi") echo "vim-minimal" ;;
        "GIMP") echo "gimp" ;;
        "Brasero") echo "brasero" ;;
        "Yandex Browser") echo "yandex-browser-stable" ;;
        "libre office") echo "libreoffice" ;;
        "testdiskwipefreespace") echo "testdisk" ;;
        "evolutiongparted") echo "evolution" ;;
        "atrilsane-airscan") echo "sane-airscan" ;;
        *) echo "$prog" ;;
    esac
}

# Проверка установки пакета
is_installed() {
    rpm -q "$1" &>/dev/null
}

# Проверка наличия пакета в репозитории
is_in_repo() {
    dnf list available "$1" 2>/dev/null | grep -q "^$1\."
}

# Временные файлы для категорий
tmp_installed=$(mktemp)
tmp_repo=$(mktemp)
tmp_missing=$(mktemp)
trap 'rm -f "$tmp_installed" "$tmp_repo" "$tmp_missing"' EXIT

# Основной цикл — пишем в файлы
for prog in "${packages[@]}"; do
    pkg=$(resolve_pkg_name "$prog")

    if is_installed "$pkg"; then
        echo "$prog" >> "$tmp_installed"
    elif is_in_repo "$pkg"; then
        echo "$prog" >> "$tmp_repo"
    else
        echo "$prog" >> "$tmp_missing"
    fi
done

# Сортировка файлов (ignore case)
sort -f -o "$tmp_installed" "$tmp_installed"
sort -f -o "$tmp_repo" "$tmp_repo"
sort -f -o "$tmp_missing" "$tmp_missing"

# Подсчёт количества
count_installed=$(wc -l < "$tmp_installed")
count_repo=$(wc -l < "$tmp_repo")
count_missing=$(wc -l < "$tmp_missing")

# === Блок 1: Установленные ===
echo -e "${BOLD}${GREEN}========================================${NC}"
echo -e "${BOLD}${GREEN}  УСТАНОВЛЕНО (${count_installed})${NC}"
echo -e "${BOLD}${GREEN}========================================${NC}"
if [ "$count_installed" -eq 0 ]; then
    echo "  (нет)"
else
    while IFS= read -r p; do
        echo -e "  ${GREEN}${NC} $p"
    done < "$tmp_installed"
fi
echo ""

# === Блок 2: Есть в репозитории ===
echo -e "${BOLD}${YELLOW}========================================${NC}"
echo -e "${BOLD}${YELLOW}  ЕСТЬ В РЕПОЗИТОРИИ (${count_repo})${NC}"
echo -e "${BOLD}${YELLOW}========================================${NC}"
if [ "$count_repo" -eq 0 ]; then
    echo "  (нет)"
else
    while IFS= read -r p; do
        echo -e "  ${YELLOW}${NC} $p"
    done < "$tmp_repo"
fi
echo ""

# === Блок 3: Отсутствуют везде ===
echo -e "${BOLD}${RED}========================================${NC}"
echo -e "${BOLD}${RED}  ОТСУТСТВУЮТ ВЕЗДЕ (${count_missing})${NC}"
echo -e "${BOLD}${RED}========================================${NC}"
if [ "$count_missing" -eq 0 ]; then
    echo "  (нет)"
else
    while IFS= read -r p; do
        echo -e "  ${RED}${NC} $p"
    done < "$tmp_missing"
fi
echo ""

# === Итог ===
echo -e "${BOLD}========================================${NC}"
echo -e "${BOLD}  ИТОГО: проверено ${#packages[@]} программ${NC}"
echo -e "${BOLD}========================================${NC}"
echo -e "  ${GREEN}Установлено:${NC}              ${count_installed}"
echo -e "  ${YELLOW}Есть в репозитории:${NC}       ${count_repo}"
echo -e "  ${RED}Отсутствует везде:${NC}        ${count_missing}"
